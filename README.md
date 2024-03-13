# Katello

[![Build Status](https://ci.theforeman.org/buildStatus/icon?job=katello-nightly-release)](https://ci.theforeman.org/job/katello-nightly-release/)
[![Code Climate](https://codeclimate.com/github/Katello/katello/badges/gpa.svg)](https://codeclimate.com/github/Katello/katello)

Full documentation is at https://www.theforeman.org/plugins/katello/

## About

[Katello](https://www.theforeman.org/plugins/katello/) is a systems life cycle management
plugin to [Foreman](https://www.theforeman.org). Katello allows you to manage
thousands of machines with one click. Katello can pull content
from remote repositories into isolated environments, and make subscriptions
management a breeze.

Currently, it is able to handle Fedora and Red Hat Enterprise
Linux based systems.

## Development

The most common way to set up Katello for development is to use
[forklift](https://github.com/theforeman/forklift).
This will set up a virtual machine with the Katello codebase checked out.
Please use the forklift documentation found in the repository for how
to get started with forklift.

If you have questions about or issues with deploying a development environment, feel free to ask
for assistance in #theforeman-dev IRC channel on libera.chat or via the
[community forum](https://community.theforeman.org/)

### Test Run

At this point, the development environment should be completely setup and the Katello engine functionality available. To verify this, go to your Foreman checkout:

1. Start the development server

    ```bash
    cd $GITDIR/foreman

    bundle exec foreman start
    ```

1. Access Foreman in your browser (e.g. `https://<hostname>/`). Note that while Rails will listen on port 3000, the dev installer will set up a reverse proxy so HTTPS on port 443 will work.
1. The first time you do this, you will need to accept the self-signed certificate on port 3808 by first visiting `https://<hostname>:3808`
1. Login to Foreman (default: `admin` and `changeme`)
1. If you go to `https://<hostname>/about` and view the "Plugins" tab, you should see a "Katello" plugin listed.

### Reset Development Environment

In order to reset the development environment, all backend data and the database needs to be reset. To reiterate, *the following will destroy all data in Pulp, Candlepin and your Foreman/Katello database*. From the Foreman checkout run:

```bash
rake katello:reset
```

## Found a bug?

That's rather unfortunate. But don't worry! We can help. Just file a bug
[in our project tracker](https://projects.theforeman.org/projects/katello).


## Contributing

See the [developer documentation](https://www.theforeman.org/plugins/katello/developers).

## Annotated Pulp and Candlepin Workflows and test Scenarios

See the [annotation docs](./test/scenarios/annotations/README.md) for more information.

## Contact & Resources

 * [theforeman.org](https://theforeman.org/plugins/katello)
 * [Discourse Forum](https://theforeman.org/support.html#DiscourseForum)
 * Archived mailing lists:
    * [Foreman User Mailing List](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
    * [Foreman Developer mailing list](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)

## Documentation

Most of our documentation (both for users and developers) can be found at
[theforeman.org](https://www.theforeman.org/plugins/katello).
