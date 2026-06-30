FROM alpine:3.20

RUN apk add --no-cache curl bash

WORKDIR /app

COPY ddns.sh .
RUN chmod +x ddns.sh

CMD ["/app/ddns.sh"]