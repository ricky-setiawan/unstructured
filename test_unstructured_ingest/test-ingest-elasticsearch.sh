#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"/.. || exit 1
echo "SCRIPT_DIR: $SCRIPT_DIR"
OUTPUT_FOLDER_NAME=elasticsearch
OUTPUT_DIR=$SCRIPT_DIR/structured-output/$OUTPUT_FOLDER_NAME
DOWNLOAD_DIR=$SCRIPT_DIR/download/$OUTPUT_FOLDER_NAME

# shellcheck source=/dev/null
sh scripts/elasticsearch-test-helpers/create-and-check-es.sh
wait

# Kill the container so the script can be repeatedly run using the same ports
trap 'echo "Stopping Elasticsearch Docker container"; docker stop es-test' EXIT

PYTHONPATH=. ./unstructured/ingest/main.py \
    elasticsearch \
    --download-dir "$DOWNLOAD_DIR" \
    --metadata-exclude filename,file_directory,metadata.data_source.date_processed,metadata.last_modified,metadata.detection_class_prob,metadata.parent_id,metadata.category_depth  \
    --num-processes 2 \
    --preserve-downloads \
    --reprocess \
    --output-dir "$OUTPUT_DIR" \
    --verbose \
    --index-name movies \
    --url http://localhost:9200 \
    --jq-query '{ethnicity, director, plot}'

echo "SCRIPT_DIR: $SCRIPT_DIR"
sh "$SCRIPT_DIR"/check-diff-expected-output.sh $OUTPUT_FOLDER_NAME
