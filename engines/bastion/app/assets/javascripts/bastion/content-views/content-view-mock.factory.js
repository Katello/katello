/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentView
 *
 * @description
 *   Provides a mock $Resource for interacting with content views.
 */
angular.module('Bastion.content-views').factory('ContentView',
    [function () {

        var Resource = function (id, create) {
            var name = id ? 'Content View ' + id : '',
                label = id ? 'content_view_' + id : '',
                generatedVersions = [],
                counts = {
                    products: 0,
                    repositories: 0,
                    puppetModules: 0
                };

            this.id = id;

            if (id !== undefined && !create) {
                versions.call(this, function (response) {
                    generatedVersions = response.results;
                });

                counts = {
                    products: id + id,
                    repositories: id * id,
                    puppetModules: id * id - id
                };
            }

            return {
                id: id,
                name: name,
                label: label,
                created: new Date(),
                environments: [
                    'Library',
                    'Dev'
                ],
                counts: counts,
                user: 'mister manager',
                permissions: {
                    editable: true
                },
                organization: {
                    id: 1,
                    name: 'ACME_Corporation'
                },
                $save: save,
                $versions: versions,
                $version: version,
                versions: generatedVersions,
                repositories: [],
                filters: [],
                $publish: publish,
                $puppetModules: puppetModules,
                $filters: filters,
                $addFilter: addFilter
            };
        };

        var Version = function (id) {
            return {
                id: id,
                name: 'Version ' + id,
                label: 'version_' + id,
                promoted: new Date(),
                environments: [
                    {
                        id: 1,
                        name: 'Library'
                    }, {
                        id: 2,
                        name: 'Dev'
                    }
                ],
                counts: {
                    products: id + id,
                    repositories: id * id,
                    packages: id * id,
                    puppetModules: id * id - id,
                    errata: {
                        bugs: id,
                        security: id + id,
                        enhancements: id
                    }
                },
                user: 'mister manager'
            };
        };

        var Filter = function (id) {
            return {
                id: id,
                name: 'Version ' + id,
                created: new Date(),
                description: '',
                contentType: '',
                counts: {
                    products: 0,
                    repositories: 0,
                    packages: 0,
                    puppetModules: id * id - id,
                    errata: {
                        bugs: 0,
                        security: 0,
                        enhancements: 0
                    }
                }
            };
        };

        var save = function (successCallback) {
            var view = new Resource(results.length + 1, true);

            view.name = this.name;

            results.push(view);
            successCallback(view);
        };

        var versions = function (callback) {
            var versions = generateVersions(this.id);

            if (this.id < 10) {
                this.versions = versions;
            }

            callback({
                offset: 0,
                total: versions.length,
                subtotal: versions.length,
                limit: 25,
                search: "",
                sort: {by: "name", order: "ASC"},
                results: this.versions
            });
        };

        var version = function (params, callback) {
            var found;

            angular.forEach(this.versions, function (version) {
                if (params.toString() === version.id.toString()) {
                    found = version;
                }
            });

            callback(found);
        };

        var publish = function (params, callback) {
            var version = new Version(this.versions.length + 1);

            version.name = params.name;

            this.versions.push(version);
            callback(version);
        };

        var puppetModules = function (callback) {
            var modules = [];

            if (this.modules.length === 0) {
                this.modules = modules;
            }

            callback({
                offset: 0,
                total: modules.length,
                subtotal: modules.length,
                limit: 25,
                search: "",
                sort: {by: "name", order: "ASC"},
                results: this.modules
            });
        };

        var filters = function (callback) {
            var filters = this.filters;

            callback({
                offset: 0,
                total: filters.length,
                subtotal: filters.length,
                limit: 25,
                search: "",
                sort: {by: "name", order: "ASC"},
                results: filters
            });
        };

        var addFilter = function (params, callback) {
            var filter = new Filter(this.filters.length + 1);

            filter.name = params.name;
            filter.description = params.description;
            filter.contentType = params.contentType;

            this.filters.push(filter);
            callback(filter);
        };

        Resource.query = function (params, callback) {
            callback({
                offset: 0,
                total: 10,
                subtotal: 10,
                limit: 25,
                search: "",
                sort: {by: "name", order: "ASC"},
                results: results
            });
        };

        Resource.get = function (params, callback) {
            var view;

            angular.forEach(results, function (result) {
                if (params.id.toString() === result.id.toString()) {
                    view = result;
                }
            });

            callback(view);

            return view;
        };

        function generateViews(numViews) {
            var views = [],
                i;

            for (i = 1; i <= numViews; i += 1) {
                views.push(new Resource(i));
            }

            return views;
        }

        function generateVersions(numVersions) {
            var versions = [],
                i;

            for (i = 1; i <= numVersions; i += 1) {
                versions.push(new Version(i));
            }

            return versions;
        }

        var results = generateViews(10, save, versions, publish);

        return Resource;

    }]
);
