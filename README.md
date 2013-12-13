# Katello [![Build Status](https://travis-ci.org/Katello/katello.png?branch=master)](https://travis-ci.org/Katello/katello)

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

The easiest way to set up katello, is to install the latest version of katello
via rpm, and then clone the git code.

Follow the [install steps](https://fedorahosted.org/katello/wiki/Install) from
the Katello Wiki. When you attempt to install the packages, please install the
following:

```bash
# yum install -y katello-all
```

Then, clone this repository into a workspace of your choosing.

### Setup Foreman

Start by cloning Foreman beside your git checkout of Katello such that:

```
workspace/
    foreman/
    katello/
```

Change directories into the Foreman checkout and copy the sample settings and database files:

```bash
cd foreman
cp config/settings.yaml.example config/settings.yaml
cp config/database.yml.example config/database.yml
```

Edit `config/settings.yaml`:

```yml
:require_ssl: false
# ...
:organizations_enabled: true
```

Ensure you have ```libvirt-devel``` installed:

```bash
sudo yum install libvirt-devel
```

Now create a local gemfile with the Katello engine gem, then install dependencies:

```bash
echo "gem 'katello', :path => '../katello'" >> bundler.d/Gemfile.local.rb
bundle update
```

Finally, create, migrate, and seed the database:

```bash
rake db:create db:migrate db:seed
```

### Setup Katello

The Katello setup assumes that you have a previously setup Foreman checkout or have followed the instructions in the Setup Foreman section. The first step is to add the Katello engine and install dependencies:

```bash
echo "gemspec :path => '../katello'", :development_group => :katello_dev >> bundler.d/Gemfile.local.rb
bundle update
```

Now add the Katello migrations and initial seed data:

```bash
rake db:migrate && rake db:seed
```

If you have set ```RAILS_RELATIVE_URL_ROOT``` in the past then you need to be sure to ```unset``` it and remove it from ```.bashrc``` or ```.bash_profile``` as appropriate.

```bash
unset RAILS_RELATIVE_URL_ROOT
```

Make sure that `use_ssl: false` is set in `config/katello.yml`. (**debatable**)

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
[on our Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Katello) or
[in Github](https://github.com/Katello/katello/issues).


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
