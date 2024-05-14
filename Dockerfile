FROM httpd:2.4
COPY binaries /usr/local/apache2/htdocs/binaries
COPY index.html /usr/local/apache2/htdocs/index.html
