Katello [![Build Status](https://travis-ci.org/Katello/katello.png?branch=master)](https://travis-ci.org/Katello/katello)
=======

Full documentation is at http://katello.github.io/katello

About
-----

[Katello](http://www.katello.org) is a systems life cycle management
tool. It allows you to manage hundreds and thousands machines with one
click. Katello can pull content from remote repositories into isolated
environments, make subscriptions management easier and provide
provisioning at scale.

Currently, it is able to handle Fedora and Red Hat Enterprise
Linux based systems.

Getting Started
---------------

The easiest way to get stable version of Katello up and running is following
[Katello Wiki Installation Instructions](https://fedorahosted.org/katello/wiki/Install).

If you like living on the edge, go for
[nightly builds](https://fedorahosted.org/katello/wiki/InstallTesting)
instead.

Found a bug?
------------

That's rather unfortunate. But don't worry! We can help. Just file a bug
[on our Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Katello) or
[in Github](https://github.com/Katello/katello/issues).


Contributing
------------

See
[development instructions](https://fedorahosted.org/katello/wiki/AdvancedInstallation#GettingupandRunningGIT).

What's included in this repository:

 * script - various development scripts
 * actual Rails app of Katello

Contact & Resources
-------------------

 * [Katello.org](http://katello.org)
 * [Wiki](https://fedorahosted.org/katello/wiki)
 * [User mailing list](https://fedorahosted.org/mailman/listinfo/katello)
 * [Developer mailing list](https://www.redhat.com/mailman/listinfo/katello-devel)
 * [IRC Freenode](http://freenode.net/using_the_network.shtml): #katello
 * [Twitter](https://twitter.com/Katello_Project)

Documentation
-------------

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
