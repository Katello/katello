# Katello Rails app documentation 

## Guides

- {file:doc/ForemanIntegration.md}
- {file:doc/RailsReadme}

## How to generate this doc

- go to Katello src `cd katello/src`
- generate the documentation (it will use `src/.yardopts` automatically) `yard`

### Viewing

- open statically generated documentation `open yardoc/index.html`
- or run server which will regenerate any changes made to files `yard server --reload` and go to {http://localhost:8808}
