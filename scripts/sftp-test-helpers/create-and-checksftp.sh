
#!usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# user=sftpadmin
# pass=sftpadmin

function upload(){
    # Copy the local .csv file to the Docker container
    docker cp "$SCRIPT_DIR"/wiki_movie_plots_small.csv sftp-test:/home/foo/upload/
#   echo "Uploading test content to new bucket in minio"
#   AWS_REGION=$region AWS_SECRET_ACCESS_KEY=$secret_key AWS_ACCESS_KEY_ID=$access_key \
#   aws --output json --endpoint-url $endpoint_url s3api create-bucket --bucket $bucket_name | jq
#   AWS_REGION=$region AWS_SECRET_ACCESS_KEY=$secret_key AWS_ACCESS_KEY_ID=$access_key \
#   aws --endpoint-url $endpoint_url s3 cp "$SCRIPT_DIR"/wiki_movie_plots_small.csv s3://$bucket_name/
}

# Create Minio single server
docker compose version
docker compose -f "$SCRIPT_DIR"/docker-compose.yaml up --wait
docker compose -f "$SCRIPT_DIR"/docker-compose.yaml ps

echo "Cluster is live."
upload

# Verify that the .csv file was successfully copied
# docker exec sftp-test ls /home/foo/upload