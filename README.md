# Dune binaries distribution

This is a webpage for `dune` binaries distribution for `Dune developer Preview`. The page is writen in mardown file and translated in html for deployment.

## Update index.html

- Translate `index.md`:
  ```
  $ hmd2html -i index.md
  $ ls output
  index.html
  ```

- Move the `output/index.html` to `index.html`
  ```
  $ mv output/index.html index.html
  ```

- Do not forget to add the plausible script in `index.html`
  ```
  <script defer data-domain="dune.ci.dev" src="https://plausible.ci.dev/js/script.file-downloads.js"></script>
  ```
  The plausible script is about tracking the binaries downloads.

- Push the update file `index.html` to the main branch.

## Deployment
There's a docker-compose file to help deploying the service.