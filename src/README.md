# Katello Rails app documentation 

## Guides

- {file:doc/ForemanIntegration.md}
- {file:doc/RailsReadme}

## How to generate this doc

- go to Katello src `cd katello/src`
- generate the documentation (it will use `src/.yardopts` automatically) `yard`

### Viewing

There are several options

- start Katello server and click on the link in the footer

  - or go directly to {http://katello.path/prefix/yard/docs}

- open statically generated documentation `open yardoc/index.html`

  - run `yard doc` to generate the files first

- run server `yard server --reload` and go to {http://localhost:8808}
