# Katello

[![Build Status](http://ci.theforeman.org/buildStatus/icon?job=test_katello)](http://ci.theforeman.org/job/test_katello)
[![Code Climate](https://codeclimate.com/github/Katello/katello/badges/gpa.svg)](https://codeclimate.com/github/Katello/katello)
[![Dependency Status](https://gemnasium.com/Katello/katello.svg)](https://gemnasium.com/Katello/katello)

Full documentation is at http://www.katello.org

## About

[Katello](http://www.katello.org) is a systems life cycle management
plugin to [Foreman](http://www.theforeman.org). Katello allows you to manage
thousands of machines with one click. Katello can pull content
from remote repositories into isolated environments, and make subscriptions
management a breeze.

Currently, it is able to handle Fedora and Red Hat Enterprise
Linux based systems.

## Development

The most common way to set up Katello for development is to use
[katello-deploy](https://github.com/Katello/katello-deploy#development-deployment).
This will set up a Vagrant instance with the Katello codebase checked out. You
can also run `setup.rb` directly with katello-deploy if you prefer to not use
Vagrant.

There is also
[katello-devel-installer](https://github.com/Katello/katello-installer#development-usage)
if you would like to use that.

If you have questions or issues with any of the above methods, feel free to ask
for assistance on #theforeman-dev IRC channel or via the foreman-dev mailing
list.

### Test Run

At this point, the development environment should be completely setup and the Katello engine functionality available. To verify this, go to your Foreman checkout:

1. Start the development server

    ```bash
    cd $GITDIR/foreman

    rails s
    ```

1. Access Foreman in your browser (e.g. `https://<hostname>/`). Note that while Rails will listen on port 3000, the dev installer will set up a reverse proxy so HTTPS on port 443 will work.
1. Login to Foreman (default: `admin` and `changeme`)
1. If you go to `https://<hostname>/about` and view the "Plugins" tab, you should see a "Katello" plugin listed.

### Reset Development Environment

In order to reset the development environment, all backend data and the database needs to be reset. To reiterate, *the following will destroy all data in Pulp, Candlepin and your Foreman/Katello database*. From the Foreman checkout run:

```bash
rake katello:reset
```

## Found a bug?

That's rather unfortunate. But don't worry! We can help. Just file a bug
[in our project tracker](http://projects.theforeman.org/projects/katello).


## Contributing

See the [developer documentation](http://www.katello.org/developers/index.html).

## Annotated Pulp and Candlepin Workflows and test Scenarios

See the [annotation docs](./test/scenarios/README.md) for more information.

## Contact & Resources

 * [Katello.org](http://katello.org)
 * [Foreman User Mailing List](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
 * [Foreman Developer mailing list](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)
 * [IRC Freenode](http://freenode.net/using_the_network.shtml): #theforeman-dev

## Documentation

Most of our documentation (both for users and developers) can be found at
[Katello.org](http://www.katello.org).
