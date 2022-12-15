FROM alpine:3.2
RUN apk update
RUN apk add curl bash

WORKDIR /
COPY data-exporter.sh .
RUN chmod +x data-exporter.sh
ENTRYPOINT ["data-exporter.sh"]
