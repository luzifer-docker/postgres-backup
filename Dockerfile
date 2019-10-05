FROM alpine:latest as prefetch

RUN set -ex \
 && apk --no-cache add \
     curl \
 && mkdir -p /src \
 && curl -sSfLo /src/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64" \
 && chmod 0755 /src/dumb-init


FROM postgres:9.6

COPY --from=prefetch  /src/dumb-init  /usr/local/bin/dumb-init
COPY                  pgbackup.sh     /usr/local/bin/pgbackup.sh

ENTRYPOINT ["/usr/local/bin/dumb-init"]
CMD ["/bin/bash", "/usr/local/bin/pgbackup.sh"]
