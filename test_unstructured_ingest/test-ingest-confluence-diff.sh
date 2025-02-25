#!/usr/bin/env bash
set -e

# Description: This test checks if all the processed content is the same as the expected outputs

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"/.. || exit 1

OUTPUT_FOLDER_NAME=confluence-diff
OUTPUT_DIR=$SCRIPT_DIR/structured-output/$OUTPUT_FOLDER_NAME
DOWNLOAD_DIR=$SCRIPT_DIR/download/$OUTPUT_FOLDER_NAME

if [ -z "$CONFLUENCE_USER_EMAIL" ] || [ -z "$CONFLUENCE_API_TOKEN" ]; then
   echo "Skipping Confluence ingest test because the CONFLUENCE_USER_EMAIL or CONFLUENCE_API_TOKEN env var is not set."
   exit 0
fi

PYTHONPATH=. ./unstructured/ingest/main.py \
    confluence \
    --download-dir "$DOWNLOAD_DIR" \
    --metadata-exclude filename,file_directory,metadata.data_source.date_processed,metadata.last_modified,metadata.detection_class_prob,metadata.parent_id,metadata.category_depth \
    --num-processes 2 \
    --preserve-downloads \
    --reprocess \
    --output-dir "$OUTPUT_DIR" \
    --verbose \
    --url https://unstructured-ingest-test.atlassian.net \
    --user-email "$CONFLUENCE_USER_EMAIL" \
    --api-token "$CONFLUENCE_API_TOKEN" \
    --spaces testteamsp,MFS

sh "$SCRIPT_DIR"/check-diff-expected-output.sh $OUTPUT_FOLDER_NAME
