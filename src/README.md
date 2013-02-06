# Katello Rails app developer documentation

## What can be found here?

YARD documentation is intended for developers. This documentation contains:

-   code documentation
-   high level guides to architectures and implementation details

User documentation can be found on [wiki](https://fedorahosted.org/katello/).

*Note: older developer guides can be found on wiki, they have not been migrated.*

### Guides

-   {file:doc/YARDDocumentation.md}
-   {file:doc/ForemanIntegration.md}
-   {file:doc/Graphs.md}
-   Original Rails generated README {file:doc/RailsReadme}, we may do certain things differently

    -   we use `doc` directory for storing markdown guides instead of a generated documentation

### Source

-   {Katello::Configuration}
-   {Notifications}

## How to YARD

-   to see YARD documentation start Katello server and click on the link in the UI footer or go directly to
    {http://path.to.katello/a_prefix/yard/docs/katello/frames}

    -   if it fails run `bundle exec yard doc --no-cache` first

-   see {file:doc/YARDDocumentation.md}

