(lang dune 3.16)

(name sandworm)

(generate_opam_files true)

(source
 (github tarides/dune-binary-distribution))

(authors "Etienne Marais <dev@maiste.fr>")

(maintainers "Etienne Marais <dev@maiste.fr>")

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
  crunch
  (ocaml-lsp-server :with-dev-setup)
  (ocamlformat :with-dev-setup)))

(dialect
 (name mlx)
 (implementation
  (extension mlx)
  (merlin_reader mlx)
  (preprocess
   (run mlx-pp %{input-file}))))
