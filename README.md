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

To setup a development environment begin with following the standard setup for Katello from git instructions - [development instructions](https://fedorahosted.org/katello/wiki/AdvancedInstallation#GettingupandRunningGIT). From here on in, the assumption is that you have installed Katello and converted your setup to a git checkout. If you already have a Foreman git checkout, skip ahead to the section on setting Katello up, otherwise follow the instructions below to setup a local git checkout of Foreman.

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
cp config/settings.yaml.sample settings.yaml
cp config/database.yml.sample database.yml
```

Edit `config/settings.yaml`:

```yml
:require_ssl: false
# ...
:organizations_enabled: true
```

Now create a local gemfile, add two basic gems and install dependencies:

```bash
touch bundler.d/Gemfile.local.rb
echo "gem 'facter'" >> bundler.d/Gemfile.local.rb
echo "gem 'puppet'" >> bundler.d/Gemfile.local.rb
bundle install
```

Finally, create and migrate the database:

```bash
rake db:create db:migrate
```

### Setup Katello

The Katello setup assumes that you have a previously setup Foreman checkout or have followed the instructions in the Setup Foreman section. The first step is to add the Katello engine and install dependencies:

```bash
echo "gem 'katello', :path => '../katello'" >> bundler.d/Gemfile.local.rb
bundle update
```

Now add the Katello migrations and initial seed data:

```bash
rake db:migrate && rake db:seed
```

Make sure that `use_ssl: false` is set in `config/katello.yml`. (**debatable**)

At this point, the development environment should be completely setup and the Katello engine functionality available. To verify this:

1. Start the development server

    ```bash
    pwd
    ~/workspace/foreman

    rails s
    ```

2. Access Foreman in your browser (e.g. `http://<hostname>:3000/`)
3. Login to Foreman (default: `admin` and `changeme`)
4. Create an initial Foreman organization
5. Navigate to the Katello engine (e.g. `http://<hostname>:3000/katello`)

### Reset Development Environment

In order to reset the development environment, all backend data and the database needs to be reset. To reiterate, the following will destroy all data in Pulp, Candlepin and your Foreman/Katello database. From the Foreman checkout run:

    rake katello:reset

Now that the data has been reset, the Foreman database needs to be migrated without Katello. First, disable the Katello gem by opening `bundler.d/Gemfile.local.rb` and commenting out the inclusion of Katello.

```bash
cat bundler.d/Gemfile.local.rb
#gem 'katello', :path => '../katello'

rake db:migrate
```

Next, Katello migrations need to be added along with initial seed data. Re-enable the Katello gem, migrate and seed:

```bash
cat bundler.d/Gemfile.local.rb
gem 'katello', :path => '../katello'

bundle install
rake db:migrate && rake db:seed
```

## Found a bug?

That's rather unfortunate. But don't worry! We can help. Just file a bug
[on our Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Katello) or
[in Github](https://github.com/Katello/katello/issues).


## Contributing

See
[development instructions](https://fedorahosted.org/katello/wiki/AdvancedInstallation#GettingupandRunningGIT).

What's included in this repository:

 * script - various development scripts
 * actual Rails app of Katello

## Contact & Resources

 * [Katello.org](http://katello.org)
 * [Wiki](https://fedorahosted.org/katello/wiki)
 * [User mailing list](https://fedorahosted.org/mailman/listinfo/katello)
 * [Developer mailing list](https://www.redhat.com/mailman/listinfo/katello-devel)
 * [IRC Freenode](http://freenode.net/using_the_network.shtml): #katello
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
