#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

(cd sandworm && eval $(opam env) && dune build main.css)

if [[ -f "$PWD/main.css" ]]; then
  rm "$PWD/main.css"
fi

cp "$PWD/sandworm/_build/default/main.css" "$PWD/"
