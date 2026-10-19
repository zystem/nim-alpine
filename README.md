# nim-alpine

[Nim](https://nim-lang.org) on Alpine (musl), built from the source archive of a release, published as `ghcr.io/zystem/nim:<version>-alpine`.

The official `nimlang/nim` images are Debian only since August 2026 and the last official Alpine one is 2.2.6 (its tag `2.2.4-alpine` holds 2.2.6, which has a regression in `std/httpclient` for HTTPS
through an HTTP proxy, [nim-lang/Nim#25319](https://github.com/nim-lang/Nim/issues/25319), fixed in 2.2.8). Static binaries need musl, hence this recipe. When an official Alpine image of a version exists, use it:
the workflow opens an issue when it sees one.

```
docker pull ghcr.io/zystem/nim:2.2.12-alpine
docker run --rm -v "$PWD":/app ghcr.io/zystem/nim:2.2.12-alpine nim c -r --passL:-static hello.nim
```

- The archive of the release is checked against the digest that nim-lang.org publishes (`nim-<version>.tar.xz.sha256`), then `build.sh`, `koch boot -d:release` and `koch tools` build the compiler and `nimble`.
- Contents: Alpine 3.22, `gcc`, `g++`, `musl-dev`, `git`, OpenSSL (with headers), SQLite, PCRE2; `nim`, `nimble`, `nimgrep`, `nimpretty`, `nimsuggest` in `/usr/local/bin`; `/app` is the working directory. `linux/amd64` only.
- `versions.txt` lists the versions to keep; the version that nim-lang.org calls stable is built without being listed. A push that changes the `Dockerfile` or `versions.txt` rebuilds the listed ones; a daily run builds what is
  not published yet. `workflow_dispatch` builds one version by hand. Every build is smoke-tested after the push: the version, a static program, SSL, `nimble`.
- Actions are pinned by the hash of a commit.

Licence: MIT (the recipe; Nim has its own).
