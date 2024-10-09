FROM ocaml/opam:alpine-3.20-ocaml-5.2 AS build

RUN sudo apk update && \
  sudo apk add curl git curl-dev libev-dev openssl-dev gmp-dev && \
  sudo ln -f /usr/bin/opam-2.2 /usr/bin/opam && opam init --reinit -ni && \
  opam update -y

WORKDIR /home/opam
COPY sandworm.opam sandworm.opam
RUN opam install . --deps-only -y
COPY --chown=opam:opam . .
RUN opam exec -- dune build --release

FROM alpine:3.20 AS run
RUN apk update && apk add --update libev gmp git
WORKDIR /app
COPY --from=build /home/opam/static static
COPY --from=build /home/opam/metadata.json ./metadata.json
COPY --from=build /home/opam/_build/install/default/bin/sandworm /bin/sandworm
EXPOSE 80
CMD [ "sandworm", "serve", "--port", "80"]
