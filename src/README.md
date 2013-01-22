# Katello Rails app developer documentation

## What can be found here?

YARD documentation is intended for developers. This documentation contains:

- code documentation
- high level guides to architectures and implementation details

User documentation can be found on [wiki](https://fedorahosted.org/katello/).

*Note:* older guides can be found on wiki, they have not been migrated.

### Guides

- {file:doc/ForemanIntegration.md}
- {file:doc/RailsReadme}
- {file:doc/Graphs.md}
- {file:doc/HowToDocument.md}

### Source

- {Katello::Configuration}
- {Notifications}

## YARD

### How to generate this documentation

- go to rails home

      !!!txt
      cd katello/src

- generate the documentation (it will use `src/.yardopts` automatically)

      !!!txt
      yard doc

### Browsing the documentation

There are several options

1. start Katello server and click on the link in the footer or go directly to {http://path.to.katello/a_prefix/yard/docs/katello/frames}
1. open statically generated documentation `open yardoc/index.html`, run `yard doc` to generate the files first
1. run standalone server `yard server --reload` and go to {http://localhost:8808}
