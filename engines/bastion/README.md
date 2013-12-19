# Bastion: The Katello UI Engine #

Bastion is angularjs based web client for the Katello server. The code can be found in the Katello code base at the `engines/bastion` path. The layout of the engine is:

    app/assets/bastion - application folder for all the JavaScript and view templates
    app/assets/bastion/bastion.js - Rails asset pipeline manifest
    app/assets/bastion/bastion.module.js - master application module that loads up all sub-modules
    app/assets/bsation/stylesheets - stylesheets used for the UI
    
    lib/bastion - contains the Rails engine definition and initializes to make assets available to Rails

    test/ - contains JavaScript tests broken down by the same structure as the application

    vendor/assets/javascripts - third party JavaScript libraries
    vendor/assets/stylesheets - third party stylesheets
    vendor/assets/fonts - third party fonts

    Gruntfile.js - defines the project tasks that can be run with `grunt` (e.g. `grunt ci`)
    karma.conf.js - JavaScript test configuration for the Karma test runner
    package.json - defines what nodejs modules are needed for development
    bower.json - defines the web assets needed for development and testing

## Contributing ##

For code to be accepted upstream, the following conditions must be met:

* All code must be tested
* All code must be linted
* All code must be documented

To help with this, we recommend running the following before opening a pull request:

    grunt ci

## Dependencies ##

Web asset dependencies are stored in `bower.json`. This file denotes what library files are being used and their versions.

### Installing a New Dependency ###

In order to add a new web asset dependency, a new entry into the `bower.json` file must be made along with noting what file(s) to extract from the new package to be placed into source control. For example, to add the `angular-blocks` library, open `bower.json` and add an entry under the `dependencies` section:

    "angular-blocks": "~>0.1.8"

Since Bower is based off the use of a git repository to define the package contents, installing `angular-blocks` will pull down more files than we want. In order to limit the files places into source control, add an entry to the `exportsOverride` section like so:

    "angular-blocks": {
      "javascripts/bastion": "src/angular-blocks.js"
    }

If needing to extract multiple asset types, one can do:

    "alchemy": {
      "javascripts/bastion": "alchemy.js",
      "stylesheets/bastion": "*.scss"
    }

A set of files can be included by using an array instead of a string to list the files. After defining the new dependency and the associated file(s), run the following to install the new library:

    grunt bower:install

### Updating a Dependency ###

To update a dependency, the version must be bumped in the `bower.json` file, installed and committed to source control. To bump the version, open `bower.json`, locate the proper entry and change the version number. Now, install the new version:

    grunt bower:update

Lastly, double check the new files with something like `git status`, add them and commit them with a message indicating that a new dependency version is being committed. We prefer that when committing a new depenendency, a single commit is generated with just the changes from the update.

### Example Dependency Errors ###

[See *Fixing Dependency Errors*](#fixing-dependency-errors) for more commands to help fix errors such as these:

**Error 1: local Npm module not installed**

`Local Npm module "grunt-angular-gettext" not found. Is it installed?`

Running `npm install` and `grunt bower:dev` again should fix the issue.

**Error 2: the unmet dependency**

*Traceback abbreviated to highlight error*

```
npm WARN unmet dependency /usr/lib/node_modules/block-stream requires inherits@'~2.0.0' but will load
npm WARN unmet dependency undefined
```

Running `sudo npm update -g phantomjs bower grunt-cli` should fix the issue.

### Fixing Dependency Errors ###

[See *Example Dependency Errors*](#example-dependency-errors) to see common errors and their fixes.

Over time libraries, packages, and/or dependencies are often updated or added so you may have to rerun one or more
of the following commands to fix them:

**Note**: You only need to run `grunt bower update` when updating or pulling in changes to `bower.json` where the
version of a component has been bumped.

[See also *Installing a New Dependency*](#installing-a-new-dependency) as well as the related section
[*Updating a New Dependency*](#updating-a-new-dependency)

- `sudo npm update -g phantomjs bower grunt-cli`
- `npm install`
- `grunt bower:dev`

## Testing ##

The Bastion JavaScript test suite requires the use of nodejs to be run. Nodejs is currently available for Fedora 18, Fedora 19 and EPEL. See here for more information - https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#fedora

#### Requires ####

The minimum required libraries for running the test suite is the follow (see following section for set up instructions):

* nodejs - JavaScript runtime platform
* npm - package manager for Nodejs libraries
* bower - JavaScript asset manager
* phantomjs - headless webkit browser used for running tests
* grunt-cli - command line tool for running user defined tasks

#### Setup Testing Environment ####

Install nodejs via the method that corresponds to your particular development environment, for example, on Fedora 18:

    sudo yum install npm

Install the required command line tools globally via npm:

    sudo npm install -g phantomjs bower grunt-cli

Ensure you are in the engines/bastion directory or change to the directory.
Install the local node modules defined within package.json:

    cd ~/path/to/mykatello/engines/bastion
    npm install

Install the JavaScript asset libraries used for testing defined within the `devDependencies` section of bower.json:

    grunt bower:dev

Run 'grunt test' to ensure test setup is working.

#### Test Commands ####

The Bastion test suite can either be run as a single test run or as a continuous test server that re-runs all tests whenever a file is updated. The test server also allows a developer to open multiple browsers (e.g. Chrome, Firefox) that the tests are run against in addition to the default PhantomJS browser.

To run a single test:

    grunt test

To run the test server:

    grunt test:server

To connect a browser to the test server, point your browser to your machine at port `8081`.

## Linting ##

#### JavaScript

To enforce JavaScript guidelines, we use the [JSHint](http://jshint.com/) library via [grunt-contrib-jshint](https://github.com/gruntjs/grunt-contrib-jshint). The configuration being used by the project is located at the root of the Bastion engine in the `.jshintrc` file.

To run the JavaScript linter:

    grunt jshint

#### HTML

To check HTML code, we use [grunt-htmlhint](https://github.com/yaniswang/grunt-htmlhint) which uses the lint checks from [HTMLHint](http://htmlhint.com/).

To run the HTML linter:

    grunt htmlhint


## Conventions ##

* 4 spaces (instead of 2), no tabs
* camelCase for variables
* CamelCase for classes, and service names
* Use empty lines to break up logical code chunks
* Spaces around the argument of an `if` statement:

        if (condition) {
        }

* A space between the function declaration and the opening curly bracket:

        myFunction(parameters) {
        }


## i18n ##

Internationalization is handled through the use of an angular-gettext (https://github.com/rubenv/angular-gettext).  Strings are marked for translation, extracted into a .pot file, translated, and then compiled into an angular object from the resulting .po files.  To mark a string for translation within an angular template:

    <h1 translate>My Header</h1>

Full interpolation support is available so the following will work:

    <h1 translate>My {{type}} Header</h1>

Plurals are also supported:

    <span translate translate-n="count" translate-plural="There are {{count}} messages">There is {{count}} message</a>

There is also a filter available.  Use this only when you cannot use the above version.  Some times you may need to use the filter version include when translating HTML attributes and when other directives conflict with the translate directive.  Syntax follows:

    <input type="text" placeholder="{{ 'Username' | translate }}" />

To mark strings for translation in javascript files use the injectable `gettext()`.  This method marks the string for translation while also returning the translated string from the translation angular object.

    var translatedString = gettext('String to translate');

To extract strings into a .pot file for translation run:

    grunt i18n:extract

To create an angular object from translated .po files run:

    grunt i18n:compile

### i18n workflow ###

1. Developers write a bunch of code, being sure to use the translate directive to mark strings for translation.
1. We have a string freeze close to our release.
1. A developer runs grunt i18n:extract to generate the application's .pot file and checks it into source control.
1. Either we point our translators at our github repository or provide them the .pot file.
1. The translators create .po files for each language and either send them back or open a PR with them.
1. Once the .po files are checked into source control a developer runs grunt i18n:compile which creates a javascript file that angular will use to populate the translations based on the user's locale.

## Basics of Adding a New Entity ##

When adding functionality that introduces a new entity that maps to an external resource, there are a few common steps that a developer will need to take.

First, create a folder in `app/assets/bastion` that is the plural version of the entity name (e.g. systems). Follow by creating a file to hold the module definition and the resource.

    mkdir app/assets/bastion/systems
    touch app/assets/bastion/systems/systems.module.js
    touch app/assets/bastion/systems/system.factory.js

##### Module #####

The module defines a namespace that all functionality dedicated to this entity will be attached to. This makes testing and composing components together easier. For example, the systems module definition might look like:

    /**
     * @ngdoc module
     * @name  Bastion.systems
     *
     * @description
     *   Module for systems related functionality.
     */
     angular.module('Bastion.systems', [
        'ngResource',
        'alchemy',
        'alch-templates',
        'ui.router',
        'Bastion.widgets'
     ]);

The module definition defines the 'Bastion.systems' namespace and tells Angular to make available the libraries `ngResource`, `alchemy`, `alch-templates`, `ui.router` and `Bastion.widgets`. These libraries are other similarly defined Angular modules.

##### Resource #####

A resource serves as a representation of an API endpoint for an entity and provides functions to make RESTful calls. Files and factories that represent external resources should be represented by their singular model name, for example the resource for systems is in `system.factory.js` and represented by:

    angular.module('Bastion.systems').factory('System',
        ['$resource', 'Routes'
        function($resource, Routes) {

            return $resource(Routes.apiSystemsPath() + '/:id/:action',
                {id: '@uuid'},
                {
                     update: {method: 'PUT'},
                     query: {method: 'GET', isArray: false},
                     releaseVersions: {method: 'GET', params: {action: 'releases'}
                }
            });

        }]
    );

Here we have created an angular factory named `System` and attached it to the `Bastion.systems` namespace. You can read more about the $resource service here - http://code.angularjs.org/1.0.7/docs/api/ngResource.$resource

##### Asset Pipeline #####

In order to get your newly created assets available to the web pages, we need to add them to the master manifest file. For our system example, open app/assets/bastion/bastion.js, add a reference to the module file and a line to load all files within our directory. We must include the module definition first so that all factories, controllers etc. that attach to the namespace have that namespace available.

Open the file:

    vim app/assets/bastion/bastion.js

Now add the following lines (with empty lines above and below for organizational purposes):

    //= require "bastion/systems/systems.module"
    //= require_tree "./systems"
