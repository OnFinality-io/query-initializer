FROM node:14-alpine

RUN apk add --no-cache \
        python3 \
        py3-pip \
        git \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

COPY ./script.sh script.sh

CMD [ "sh" "./script.sh" ]