# Nim on Alpine (musl), built from the source archive of a release, for static binaries. The official nimlang/nim images are Debian only since 2026-08; their last Alpine one is 2.2.6.
# The archive is checked against the digest nim-lang.org publishes. Same names and paths as the old official Alpine images (/usr/local/bin/nim, /app), so `FROM` is the only change.
FROM alpine:3.22
ARG NIM_VERSION
ARG NIM_SHA256
LABEL org.opencontainers.image.title="nim-alpine" \
      org.opencontainers.image.description="Nim ${NIM_VERSION} on Alpine, built from source" \
      org.opencontainers.image.source="https://github.com/zystem/nim-alpine" \
      org.opencontainers.image.licenses="MIT"
ENV NIM_VERSION=${NIM_VERSION}
RUN test -n "${NIM_VERSION}" && test -n "${NIM_SHA256}" \
 && apk add --no-cache ca-certificates git openssl openssl-dev sqlite sqlite-dev pcre2 gcc g++ musl-dev linux-headers \
 && apk add --no-cache --virtual .nim-build curl xz make \
 && mkdir -p /usr/local/src \
 && cd /usr/local/src \
 && curl -fsSL "https://nim-lang.org/download/nim-${NIM_VERSION}.tar.xz" -o nim.tar.xz \
 && echo "${NIM_SHA256}  nim.tar.xz" | sha256sum -c - \
 && tar -xJf nim.tar.xz && mv "nim-${NIM_VERSION}" nim && rm nim.tar.xz \
 && cd nim \
 && sh build.sh \
 && bin/nim c koch \
 && ./koch boot -d:release \
 && ./koch tools -d:release \
 && rm -rf csources_v2 c_code tests nimcache bin/nim_dbg /root/.cache/nim /root/.nimble/pkgs2 \
 && for b in nim nimble nimgrep nimpretty nimsuggest; do ln -sf /usr/local/src/nim/bin/$b /usr/local/bin/$b; done \
 && apk del .nim-build \
 && nim --version | head -1 && nimble --version | head -1
ENV PATH="/usr/local/bin:/root/.nimble/bin:${PATH}"
WORKDIR /app
CMD ["nim", "--version"]
