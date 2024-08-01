# Dune binaries distribution

This is a webpage for `dune` binaries distribution of `Dune developer Preview`.
The page is automatically generated from file `metadata.json`. Apart from the
_YAML_ part, the code is written in _OCaml_.

The GitHub Actions pipeline regularly creates commit on the `main` branch where
it:
- updates the content of `metadata.json`
- updates the content of `index.html`
- generates new artifacts and pushes them to their SSH storage using `RClone`

The web page is deployed on [dune.ci.dev](https://dune.ci.dev).

> :hourglass: The pipeline is triggered every day at _01:00 UTC_.


## Installation & configuration

### Requirement

You need to have `opam` available to install and build the project.

### Install

The _OCaml code_ is stored in the [sandworm](./sandworm/) directory. Install
the dependencies with the following commands:

```shell
$ cd sandworm/
$ opam install . --deps-only --with-dev-setup
```

Please note that `--with-dev-setup` should only be used for a development
purpose.

### Configure

The configuration is in [sandworm/bin/config.ml](./sandworm/bin/config.ml)
file. When running in the pipeline, the _sandworm_ binary is generated before
its execution. As a result, the path taken is the root of this repository. If
you want to run it locally, make sure the _files artifacts_ and `rclone.conf`
are available in the directory where _sandworm_ binary is executed.

The export relies on an SSH key to the server. If you want to run your own
tests, you need to have a server available by _SSH_ with an _SSH key_. Then,
you have to create a `rclone.conf` file as follows:

```toml
[dune-binary-distribution]
type = sftp
user = <username>
host = <replace.myhost.com>
key_file = </path/to/your/ssh/private/key>
shell_type = unix
```

If you don't have a `/dune` directory on your server, you might want to change
the `s3_bucket_ref` variable. It could be:

```ocaml
let s3_bucket_ref = "dune-binary-distribution:/path/to/your/server/dir"
```

> [!TIP]
> For our use case, the _RClone_ configuration works with SFTP but, it is
> compatible with any _RClone_ provider.

## Running

Now your setup is ready, you can execute this list of commands to generate or
update the files:

```shell
$ cd sandworm
$ dune build
$ cd ../
$ ls
artifacts rclone.conf
$ ./sandworm/_build/install/default/bin/sandworm
```

## Deploying

The deployment are automatically done through GitHub Actions. No need to add
extra work to deploy it.
