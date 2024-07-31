# Dune binaries distribution

This is a webpage for `dune` binaries distribution of `Dune developer Preview`. The page is automatically generated from file `metadata.json`. Apart from the _YAML_ part, the code is written in _OCaml_.

The GitHub Actions pipeline regularly creates commit on the `main` branch where it:
- updates the content of `metadata.json`
- updates the content of `index.html`
- generates new artifacts and pushes them to their SSH storage using `RClone`

The web page is deployed on [dune.ci.dev](https://dune.ci.dev).

> :hourglass: The pipeline is triggered every day at _01:00 UTC_.


## Installation & configuration

### Install

The _OCaml code_ is stored in the [./sandworm](./sandworm/) directory. To install the dependencies, just `cd` into it and us `opam`:

```shell
$ cd sandworm/
$ opam install . --deps-only --with-dev-setup
```

Please note that `--with-dev-setup` should only be used for a development purpose.

### Configure

The configuration is in [./sandworm/bin/config.ml](./sandworm/bin/config.ml) file. When running in the pipeline, the _Sandworm_ binary is generated before the execution. As a result, the path taken is the root of this repository. If you want to run it from the [./sandworm](./sandworm) directory, you have to update the path using `../[path]`.

The export relies on an SSH key to the server. If you want to run your own tests, you need to have a server available by _SSH_ with an _SSH key_. Then, you have to create a `rclone.conf` file as follows:

```toml
[dune-binary-distribution]
type = sftp
user = <username>
host = <replace.myhost.com>
key_file = </path/to/your/ssh/private/key>
shell_type = unix
```

If you don't have a `/dune` directory on your server, you might want to change the `s3_bucket_ref` variable. It could be:

```ocaml
let s3_bucket_ref = "dune-binary-distribution:/path/to/your/server/dir"
```

> [!TIP]
> For our use case, the _RClone_ configuration works with SFTP but, it is compatible with any _RClone_ provider.

## Running

Now your setup is ready, supposing you are in the [./sandworm](./sandworm) directory, you can simply run the program with:

```shell
$ dune exec -- sandworm
```

or you can build it and execute it:

```shell
$ dune build
$ ./_build/install/default/bin/sandworm
```

## Deploying

The deployment are automatically done through GitHub Actions. No need to add extra work to deploy it.
