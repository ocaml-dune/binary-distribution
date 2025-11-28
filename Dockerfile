FROM alpine:3.23 AS build

RUN apk update && \
  apk add curl git curl-dev libev-dev openssl-dev gmp-dev musl-dev linux-headers make ocaml

WORKDIR /home/opam
RUN git clone --depth=1 https://github.com/ocaml/dune.git && \
  cd dune && \
  ./configure --prefix=/usr && \
  make release && \
  make install && \
  cd .. && \
  rm -r dune
COPY . .
RUN dune build --release

FROM alpine:3.23 AS run
RUN apk update && apk add --update libev gmp git
WORKDIR /app
COPY --from=build /home/opam/static static
COPY --from=build /home/opam/metadata.json ./metadata.json
COPY --from=build /home/opam/_build/install/default/bin/sandworm /bin/sandworm
EXPOSE 80
CMD [ "sandworm", "serve", "--port", "80"]
