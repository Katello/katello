# Katello [![Dependency Status](https://gemnasium.com/Katello/katello.svg)](https://gemnasium.com/Katello/katello)

Full documentation is at http://katello.github.io/katello

## About

[Katello](http://www.katello.org) is a systems life cycle management
plugin to [Foreman](http://www.theforeman.org). Katello allows you to manage
thousands of machines with one click. Katello can pull content
from remote repositories into isolated environments, and make subscriptions
management a breeze.

Currently, it is able to handle Fedora and Red Hat Enterprise
Linux based systems.

## Development

The recommended way to set up Katello for development to use the [katello-devel-installer](https://github.com/Katello/katello-installer#development-usage) directly or via [katello-deploy](https://github.com/Katello/katello-deploy#development-deployment).

### Test Run

At this point, the development environment should be completely setup and the Katello engine functionality available. To verify this, go to your Foreman checkout:

1. Start the development server

    ```bash
    cd $GITDIR/foreman

    rails s
    ```

2. Access Foreman in your browser (e.g. `http://<hostname>:3000/`)
3. Login to Foreman (default: `admin` and `changeme`)
4. Create an initial Foreman organization
5. Navigate to the Katello engine (e.g. `http://<hostname>:3000/katello`)

### Reset Development Environment

In order to reset the development environment, all backend data and the database needs to be reset. To reiterate, the following will destroy all data in Pulp, Candlepin and your Foreman/Katello database. From the Foreman checkout run:

```bash
rake katello:reset
```

## Found a bug?

That's rather unfortunate. But don't worry! We can help. Just file a bug
[in our project tracker](http://projects.theforeman.org/projects/katello).


## Contributing

See [getting involved](http://www.katello.org/get-involved/).

## Contact & Resources

 * [Katello.org](http://katello.org)
 * [Wiki](https://fedorahosted.org/katello/wiki)
 * [Foreman User Mailing List](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
 * [Foreman Developer mailing list](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)
 * [IRC Freenode](http://freenode.net/using_the_network.shtml): #theforeman-dev
 * [Twitter](https://twitter.com/Katello_Project)

## Documentation

Documentation is generated with [YARD](http://yardoc.org/) and hosted at <http://katello.github.io/katello/>.
This documentation is intended for developers, user documentation can be found on
[wiki](https://fedorahosted.org/katello/). Developer documentation contains:

-   code documentation
-   high level guides to architectures and implementation details
-   how-tos

*Note: older developer guides can be found on our wiki, they are being migrated.*

### How to

-   to see YARD documentation start Katello server and find the link on "About" page or go directly to
    <http://path.to.katello/url_prefix/yard/docs/katello/frames>

    -   if it fails run `bundle exec yard doc --no-cache` first, which will rebuild whole documentation

-   see {file:doc/YARDDocumentation.md}

## Current documentation

-   {file:doc/YARDDocumentation.md}
-   {file:doc/Graphs.md}

### Debugging

-   {file:doc/how_to/add_praise.md Enabling Praise} - raise/exception investigation

### Packaging

-   {file:doc/how_to/package_new_gem.md How to package new gem}

### Other

-   {file:doc/katellodb.html DB schema documentation}
-   Original Rails generated README {file:doc/RailsReadme}, we may do certain things differently

    -   we use `doc` directory for storing markdown guides instead of a generated documentation

### Source

-   {Katello::Configuration}
-   {Notifications}
