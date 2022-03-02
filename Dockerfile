FROM --platform=${BUILDPLATFORM} python:3.9-slim as build
WORKDIR /dist
ARG TARGETPLATFORM
# Deps
COPY ./scripts/requirements.txt .
RUN pip3 install -r requirements.txt
# Dist + script
COPY ./target/dist/ .
COPY ./scripts/target.py .
RUN python3 ./target.py ${TARGETPLATFORM}
RUN chmod +x ./a-train

FROM --platform=${TARGETPLATFORM} alpine:latest as runtime
COPY --from=build /dist/a-train /usr/local/bin/
ARG PUID=1000 PGID=1000 USER=dokku
RUN set -ex && addgroup -g $PGID $USER && adduser -D -u $PUID -G $USER $USER
USER $USER
VOLUME /data
WORKDIR /data
ENTRYPOINT [ "/usr/local/bin/a-train" ]
