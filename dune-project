(lang dune 3.16)

(name sandworm)

(generate_opam_files true)

(source
 (github ocaml-dune/binary-distribution))

(authors
 "Etienne Marais <dev@maiste.fr>"
 "Marek Kubica <marek@tarides.com>"
 "Stephen Sherratt <stephen@sherra.tt>"
 "Ambre Austen Suhamy <ambre@tarides.com>"
 "Leandro Ostera <leandro@abstractmachines.dev>"
 "Alpha Issiaga DIALLO <alpha@tarides.com>")

(maintainers
 "Etienne Marais <dev@maiste.fr>"
 "Marek Kubica <marek@tarides.com>"
 "Stephen Sherratt <stephen@sherra.tt>"
 "Ambre Austen Suhamy <ambre@tarides.com>"
 "Leandro Ostera <leandro@abstractmachines.dev>"
 "Alpha Issiaga DIALLO <alpha@tarides.com>")

(license ISC)

(package
 (name sandworm)
 (synopsis "Dune metadata website generator")
 (description "The Dev Preview website generator.")
 (depends
  ocaml
  dune
  yojson
  ppx_deriving_yojson
  mlx
  ocamlmerlin-mlx
  ptime
  fpath
  cmdliner
  html_of_jsx
  dream
  dream-encoding
  tailwindcss
  (ocaml-lsp-server :with-dev-setup)
  (ocamlformat
   (and
    (= 0.26.2)
    :with-dev-setup))))

(dialect
 (name mlx)
 (implementation
  (extension mlx)
  (merlin_reader mlx)
  (preprocess
   (run mlx-pp %{input-file}))))

(pin
 (url
  "git+https://github.com/tmattio/opam-tailwindcss#e5bb6361a50c7cc5cad802311e609336583ca08f")
 (package
  (name tailwindcss)))
