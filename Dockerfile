# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git make clang

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/xHTTP/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/xHTTP.git
WORKDIR /xHTTP

## Build
RUN clang example2.c xhttp.c -o xhttp_server

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd xhttp_server | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /xHTTP/xhttp_server /xhttp_server
COPY --from=builder /deps /usr/lib

CMD ["/xhttp_server"]
