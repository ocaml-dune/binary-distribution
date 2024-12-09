#!/usr/bin/env bash

# add path if not already done, inspired by rustup
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed dune needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac

# completions
source "$HOME/.local/share/dune/completions/bash.sh"
