FROM alpine:3.23 AS build

RUN apk update && \
  apk add curl git curl-dev libev-dev openssl-dev gmp-dev musl-dev linux-headers make ocaml

WORKDIR /home/opam
RUN curl -fsSL https://github.com/ocaml/dune/releases/download/3.21.1/dune-3.21.1.tbz -o dune.tar.bz2 && \
  tar xf dune.tar.bz2 && \
  cd dune-* && \
  ./configure --prefix=/usr && \
  make release && \
  make install && \
  cd .. && \
  rm -r dune-*
COPY . .

RUN sed -i /dependency_hash/d dune.lock/lock.dune
RUN apk add sqlite-dev $(dune show depexts)
RUN dune build --release

FROM alpine:3.23 AS run
RUN apk update && apk add --update libev gmp git
WORKDIR /app
COPY --from=build /home/opam/static static
COPY --from=build /home/opam/metadata.json ./metadata.json
COPY --from=build /home/opam/_build/install/default/bin/sandworm /bin/sandworm
EXPOSE 80
CMD [ "sandworm", "serve", "--port", "80"]
