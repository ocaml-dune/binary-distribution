FROM ocaml/opam:alpine-3.20-ocaml-5.2 AS build

RUN sudo apk update && \
  sudo apk add curl git curl-dev libev-dev openssl-dev gmp-dev && \
  opam-2.0 update -y

WORKDIR /home/sandworm
COPY sandworm.opam sandworm.opam
RUN opam install . --deps-only -y
COPY --chown=opam:opam . .
RUN opam-2.0 exec -- dune build --release

FROM alpine:3.20 AS run
RUN apk update && apk add --update libev gmp git
WORKDIR /app
COPY --from=build /home/sandworm/static static
COPY --from=build /home/sandworm/metadata.json ./metadata.json
COPY --from=build /home/sandworm/_build/install/default/bin/sandworm /bin/sandworm
EXPOSE 80
CMD [ "sandworm", "serve", "--port", "80"]
