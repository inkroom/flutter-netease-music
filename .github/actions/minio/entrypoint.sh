#!/bin/sh -l
set -euo pipefail

mc alias set deploy $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api $MINIO_API

ls -all

mc cp --overwrite $1 "deploy/$2"