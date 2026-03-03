FROM alpine:3.23 AS build
RUN apk update && \
  apk add curl git musl-dev linux-headers make dune gcc
WORKDIR /home/sandworm
COPY . .
RUN sed -i /dependency_hash/d dune.lock/lock.dune
RUN apk add $(dune show depexts 2>&1)
RUN dune build --release

FROM alpine:3.23 AS run
RUN apk update && apk add --update libev gmp git
WORKDIR /app
COPY --from=build /home/sandworm/static static
COPY --from=build /home/sandworm/metadata.json ./metadata.json
COPY --from=build /home/sandworm/_build/install/default/bin/sandworm /bin/sandworm
EXPOSE 80
CMD ["sandworm", "serve", "--port", "80"]
