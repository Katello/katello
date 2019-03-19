# Bastion: AngularJS based Foreman UI Engine #

Bastion is a single page AngularJS based web client for the Foreman server. This means that all Bastion "pages" are served from a single static page without the need for a round trip to the server.
All URLs are relative to the application root, `/content-hosts` and `/content_views`, for example, are able to be bookmarked, and work with the browser's back button.
The only real difference, as far as the user is concerned, is that the application is much quicker between Bastion "page loads" since only the HTML needed to render the next page is loaded instead of the entire page. Bastion is designed to work in the context of Foreman and is not a stand-alone gem or engine.

## Plugins ##

Bastion is designed to provide a set of common functionality and integration points that other Foreman Plugins can take advantage. This allows UI developers to focus on implementation without having to deal with the boilerplate loading of routes and pages to enable the Single Page Application structure to work with Foreman. A basic Bastion plugin declaration looks like the following:

```
Bastion.register_plugin(
  :name => 'bastion_katello',
  :javascript => 'bastion_katello/bastion_katello',
  :stylesheet => 'bastion_katello/bastion_katello',
  :pages => %w(
    content_hosts
    content_views
  )
)
```

**name**: The name of the plugin and Rails engine being declared, this should correspond to the engine's namespace
**javascript**: The javascript files (often a Sprockets manifest) that will contain all your plugin's Javascript files
**pages**: The top level pages that your plugin is providing. This often corresponds to a top level route. For example, the activation_keys page will treat all routes rooted at `/activation_keys` as a single page HTML5 application and allow routing to be handled client side.

In order to add third party or custom AngularJS modules, add the following to your the top of your modulename.module.js file or in a separate mymodulename-bootstrap.js file):

```javascript
BASTION_MODULES.push('myModuleName');
```

### Plugin Development ###

Bastion supplies a common set of testing and development using Grunt.  To setup your development environment, from your plugin's checkout:

```
sudo npm install -g grunt-cli
npm install
npm install ../bastion/
```

To run your plugin's tests and lint them:

```
grunt ci
```

### Basics of Adding a New Entity ###

Sometimes adding new functionality requires creating a new entity which maps to an external resource. There are a few common steps that a developer will need to take.

Create a folder in `app/assets/javascripts/<plugin_name>` using the plural form of the entity name (e.g. content-hosts). Then create a file to hold the module definition and the resource.

```bash
cd app/assets/javascripts/<plugin_name>
mkdir content-hosts
touch content-hosts/content-hosts.module.js
touch content-host.factory.js
```

#### Module

The module defines a namespace that contains all functionality related to this entity. This makes testing and compining components together less coupled. For example, the content-hosts module definition might look like:

```javascript
(function () {
    'use strict';

    /**
    * @ngdoc module
    * @name  Bastion.content-hosts
    *
    * @description
    *   Module for content-hosts related functionality.
    */
    angular
        .module('Bastion.content-hosts', [
          'ngResource',
          'ui.router',
          'Bastion.components'
        ]);

})();
```

The module definition creates the 'Bastion.content-hosts' namespace and tells Angular to make available the libraries `ngResource`, `ui.router` and `Bastion.components`. These libraries are other similarly defined Angular modules.

#### Routing

In order to display a Bastion page you must add a route for the page. Start by adding a routes file:

```javascript
touch content-hosts/content-hosts.routes.js
```

Now add the basics of a route setup to the file:

```javascript
(function () {
    'use strict';

    /**
     * @ngdoc config
     * @name  Bastion.content-hosts.config
     *
     * @description
     *   Defines the routes for content-hosts
     */
    function ContentHostRoutes($stateProvider) {

    }

    angular
        .module('Bastion.content-hosts')
        .config(ContentHostRoutes);

    ContentHostRoutes.$inject = ['$stateProvider'];

})();
```

A route to view all content-hosts may look like this:

```javascript
$stateProvider.state('content-hosts.index', {
    url: '/content_hosts',
    views: {
        'table': {
            controller: 'ContentHostTableController',
            templateUrl: 'content-hosts/views/content-hosts-table-full.html'
        }
    }
});
```

The views object contains a list of addressable views that allow the association of Angular controllers and templates with a URL.
See the UI router [documentation](http://angular-ui.github.io/ui-router/site/#/api/ui.router) for more information.

#### Resource

A resource serves as a representation of an API endpoint for an entity and provides functions to make RESTful calls. User the single form of the entity for the name of the resource and filename. For example the resource for the `content-hosts` module is in `content-host.factory.js` and represented by:

```javascript
(function () {
    'use strict';

    /**
     * @ngdoc config
     * @name  Bastion.content-hosts.factory:ContentHost
     *
     * @description
     *   Defines the API endpoint for Content Host
     */
    function ContentHost(BastionResource) {
          return BastionResource('api/v2/content-hosts/:id/:action',
              {id: '@uuid'},
              {
                  update: {method: 'PUT'},
                  query: {method: 'GET', isArray: false},
                  releaseVersions: {method: 'GET', params: {action: 'releases'}
              }
          });
    }

    angular
        .module('Bastion.content-hosts')
        .factory('ContentHost', ContentHost);

    ContentHost.$inject = ['BastionResource'];

})();
```

Here we have created an angular factory named `content-host` and attached it to the `Bastion.content-hosts` namespace. It's important that the resource URL does not begin with a '/' so that the application can live in a subdirectory without errors. You can read more about the $resource service here - http://code.angularjs.org/1.0.7/docs/api/ngResource.$resource

#### Asset Pipeline

In order to get your newly created assets available to the web pages, we need to add them to the master manifest file for your plugin. For our content-host example, open app/assets/javascripts/<plugin_name>/<plugin_name>.js, add a reference to the module file and a line to load all files within our directory. We must include the module definition first so that all factories, controllers etc. that attach to the namespace have that namespace available.

Open the file, and add the following lines (with empty lines above and below for readability):

```javascript
//= require "<plugin_name>/content-hosts/content-hosts.module"
//= require_tree "./content-hosts"
```

## Developing Bastion ##

To setup a development environment, clone the repository or your fork of the repository. From the git checkout, setup the required development dependencies by running:

```
sudo npm install -g grunt-cli
npm install
```

After making changes, tests and linting can be run via:

```
grunt ci
```

### Dependencies ###

Web asset dependencies are stored in `bower.json`. This file denotes what library files are being used and their versions.

#### Installing a New Dependency ####

In order to add a new web asset dependency, a new entry into the `bower.json` file must be made along with noting what file(s) to extract from the new package to be placed into source control. For example, to add the `angular-blocks` library, open `bower.json` and add an entry under the `dependencies` section:

```javascript
"angular-blocks": "~>0.1.8"
```

Since Bower is based off the use of a git repository to define the package contents, installing `angular-blocks` will pull down more files than we want. In order to limit the files places into source control, add an entry to the `exportsOverride` section like so:

```javascript
"angular-blocks": {
  "javascripts/bastion": "src/angular-blocks.js"
}
```

If needing to extract multiple asset types, one can do:

```javascript
"bootstrap": {
  "javascripts/bastion": "bootstrap.js",
  "stylesheets/bastion": "*.scss"
}
```

A set of files can be included by using an array instead of a string to list the files. After defining the new dependency and the associated file(s), run the following to install the new library:

    grunt bower:update

#### Updating a Dependency ####

To update a dependency, the version must be bumped in the `bower.json` file, installed and committed to source control. To bump the version, open `bower.json`, locate the proper entry and change the version number. Now, install the new version:

```bash
grunt bower:update
```

Lastly, double check the new files with something like `git status`, add them and commit them with a message indicating that a new dependency version is being committed. We prefer that when committing a new depenendency, a single commit is generated with just the changes from the update.

#### Example Dependency Errors ####

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

#### Fixing Dependency Errors ####

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


## i18n ##

To extract strings into a .pot file for translation run:

```bash
grunt i18n:extract
```

To create an angular object from translated .po files run:

```bash
grunt i18n:compile
```

## Releasing Bastion ##

In order to release a new version of Bastion, the following is required:

 1. Update the version in `lib/bastion/version.rb`
 1. Commit the changes
 1. `git tag <version>`
 1. `gem build bastion.gemspec`
 1. `gem push bastion-<version>.gem`
 1. `git push origin <version>`
 1. `git push origin master`

In addition to the above the previous Bastion release in Redmine should be closed and a new release created with the
version used above.

## Contributing ##

We welcome contributions, please see the Bastion [developer guide](https://github.com/Katello/katello.org/blob/master/docs/developer_guide/bastion/index.md).
