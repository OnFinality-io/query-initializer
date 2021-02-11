#!/bin/bash

# BUCKET_NAME=""
# SUB_FOLDER=""
# GIT_REPO=https://github.com/OnFinality-io/subql-starter
# COMMIT=29dc0cf906c52fb36c6c93927293b88db86a3320

if [ -z "${BUCKET_NAME}" ]; then
    echo "BUCKET_NAME is unset"
    exit 1
fi

if [ -z "${GIT_REPO}" ]; then
    echo "GIT_REPO is unset"
    exit 1
fi

if [ -z "${COMMIT}" ]; then
    echo "COMMIT is unset"
    exit 1
fi

path=$(echo $GIT_REPO | sed -E 's/^\s*.*:\/\///g')
if [ "$SUB_FOLDER" != '' ]; then
    path=$path/$SUB_FOLDER
fi
path=$path/${COMMIT}.tar.gz

remoteFile="s3://${BUCKET_NAME}/${path}"
isExist=$(aws s3 ls ${remoteFile}  --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')

function build() {
    # pull the clode
    git clone $GIT_REPO ./data
    cd ./data
    git checkout $COMMIT
    cd ./$SUB_FOLDER

    local localFile="../${COMMIT}.tar.gz"

    # build code
    yarn
    yarn codegen
    yarn build
    tar -czf $localFile .

    # upload package
    aws s3 cp $localFile $remoteFile

    # delete local package
    rm $localFile
}


if [ $isExist == 0 ]; then
    echo "start to build package"
    build 
else
    echo "start to download package from $remoteFile"
    mkdir ./data
    localFile="${COMMIT}.tar.gz"
    aws s3 cp $remoteFile $localFile
    echo "extract from the package： $localFile"
    tar -xzf $localFile -C ./data
    rm $localFile
fi
echo "initialize done"