# Dune binaries distribution

This is a webpage for `dune` binaries distribution. The page is writen in mardown file and translated in html for deployment.

## Deployment

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

- The file `index.html` and `binaries` directory are ready to be hosted.