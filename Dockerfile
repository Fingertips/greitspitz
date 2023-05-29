FROM crystallang/crystal:1.8-alpine
RUN apk add --no-cache vips-dev vips-heif
ADD . /src/greitspitz
WORKDIR /src/greitspitz
RUN make release install && rm -Rf /src/greitspitz
CMD ["/usr/local/bin/greitspitz"]
