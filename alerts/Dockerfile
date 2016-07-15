FROM debian:jessie

RUN apt-get update \
    && apt-get install -y curl jq
COPY ./curl.sh /tmp/curl.sh

CMD ["/tmp/curl.sh"]
