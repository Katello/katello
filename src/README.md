# Katello Rails app developer documentation 

## What is documented?

### Guides

- {file:doc/ForemanIntegration.md}
- {file:doc/RailsReadme}
- {file:doc/Graphs.md}

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
      yard

### Browsing the documentation

There are several options

1. start Katello server and click on the link in the footer or go directly to {http://path.to.katello/a_prefix/yard/docs/katello/frames}
1. open statically generated documentation `open yardoc/index.html`, run `yard doc` to generate the files first
1. run standalone server `yard server --reload` and go to {http://localhost:8808}

### How to

- YARD is set to [Markdown syntax](http://daringfireball.net/projects/markdown/syntax#html) by default. Files without extension and code documentation will us it. It can be overridden by different file extension.
- [Getting started](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md) with YARD

  - [Tag list](http://rubydoc.info/docs/yard/file/docs/Tags.md#List_of_Available_Tags) is also useful
  