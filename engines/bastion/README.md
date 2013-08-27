# Bastion: The Katello UI Engine #

Bastion is angularjs based web client for the Katello server. The code can be found in the Katello code base at the `engines/bastion` path. The layout of the engine is:

    app/assets/bastion - application folder for all the JavaScript and view templates
    app/assets/bastion/bastion.js - Rails asset pipeline manifest
    app/assets/bastion/bastion.module.js - master application module that loads up all sub-modules
    app/assets/bsation/stylesheets - stylesheets used for the UI
    
    lib/bastion - contains the Rails engine definition and initializes to make assets available to Rails

    test/ - contains JavaScript tests broken down by the same structure as the application

    vendor/assets/components - third party libraries needed in production
    vendor/assets/dev-components - generated when `bower install --dev` is run, contains third party assets needed for testing

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

Install the JavaScript asset libraries used for testing defined within bower.json:

    bower install --dev

Run 'grunt test' to ensure test setup is working

#### Test Commands ####

The Bastion test suite can either be run as a single test run or as a continuous test server that re-runs all tests whenever a file is updated. The test server also allows a developer to open multiple browsers (e.g. Chrome, Firefox) that the tests are run against in addition to the default PhantomJS browser.

To run a single test:

    grunt test

To run the test server:

    grunt test:server

To connect a browser to the test server, point your browser to your machine at port `8081`.

## Linting ##

Linting is controlled by the JSHint library. The configuration being used by the project is located at the root of the Bastion engine in the `.jshintrc` file. To run just the linter:

    grunt jshint

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

Internationalization is handled through the use of an angular filter and a service side API call that retrieves a hash containing the translations based on the user's language preference. The dictionary hash takes advantage of the Ruby gettext translation service. To declare a string for i18n within an angular template:

    <h1>{{ "My Header" | i18n }}</h1>

To denote a string with replacement:

    <h1>{{ "My %type Header" | i18n:{'type': 'New'} }}</h1>

In order for a string to be included in the translation dictionary, the string must be manually entered into the internalization dictionary using the english translation as the key. This dictionary can be found at `app/views/i18n/_dictionary.haml`. To add the example entries above, we would append to the list:

    "My Header": "#{_("My Header"_)}",
    "My %type Header": "#{_("My %type Header")}"


## Basics of Adding a New Entity ##

When adding functionality that introduces a new entity that maps to an external resource, there are a few common steps that a developer will need to take.

First, create a folder in `app/assets/bastion` that is the plural version of the entity name (e.g. systems). Follow by creating a file to hold the module definition and the resource.

    mkdir app/assets/bastion/systems
    touch app/assets/bastion/systems.module.js
    touch app/assets/bastion/system.factory.js

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
        'ui.compat',
        'Bastion.widgets'
     ]);

The module definition defines the 'Bastion.systems' namespace and tells Angular to make available the libraries `ngResource`, `alchemy`, `alch-templates`, `ui.compat` and `Bastion.widgets`. These libraries are other similarly defined Angular modules.

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
