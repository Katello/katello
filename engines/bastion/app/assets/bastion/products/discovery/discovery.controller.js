/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.products.controller:DisocveryController
 *
 * @requires $scope
 * @requires $q
 * @requires $timeout
 * @requires $http
 * @requires Task
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the repo discovery action pane.
 */
angular.module('Bastion.products').controller('DiscoveryController',
    ['$scope', '$q', '$timeout', '$http', 'Task', 'Organization', 'CurrentOrganization',
    function($scope, $q, $timeout, $http, Task, Organization, CurrentOrganization) {
        var transformRows, setDiscoveryDetails;

        $scope.discovery = {url: ''};
        $scope.panel = {loading: false};

        if (!$scope.discoveryTable) {
            $scope.discoveryTable = {rows: []};
        }

        setDiscoveryDetails = function(task) {
            var discoveryAction = "Orchestrate::Katello::RepositoryDiscover";
            var input = Task.input(task, discoveryAction);

            $scope.discovery.pending = task.pending;

            if (!task.pending) {
                $scope.discovery.working = false;
            }

            if(!input) {
                return
            }
            $scope.discovery.url = input.url;
            $scope.discoveryTable.rows = transformRows(Task.output(task, discoveryAction));

        };

        $scope.setupSelected = function() {
            $scope.panel.loading = true;
            $scope.discovery.selected = $scope.discoveryTable.getSelected();
            $scope.transitionTo('products.discovery.create');
        };

        $scope.defaultName = function(basePath) {
            //Remove leading/trailing slash and replace rest with space
            return basePath.replace(/^\//, "").replace(/\/$/, "").replace(/\//g, ' ');
        };

        $scope.cancelDiscovery = function() {
            $scope.discovery.working = true;
            Organization.cancelRepoDiscover({id: CurrentOrganization});
        };

        transformRows = function(output) {
            if(!output) {
                return [];
            }
            var urls = output.repo_urls;
            var baseUrl, toRet;
            baseUrl = $scope.discovery.url;

            toRet = _.map(urls, function(url) {
                var path = url.replace(baseUrl, "");
                return {
                    url: url,
                    path: path,
                    name: $scope.defaultName(path),
                    label: ''
                };
            });

            return _.sortBy(toRet, function(item) {
                return item.url;
            });
        };

        Organization.get({id: CurrentOrganization}, function(org) {
            if (org['discovery_task_id']) {
                Task.get({id: org['discovery_task_id']}, function(task) {
                    pollTask(task);
                });
            }
        });

        $scope.discover = function() {
            $scope.discovery.pending = true;
            $scope.discoveryTable.rows = [];
            $scope.discoveryTable.selectAll(false);
            Organization.repoDiscover({id: CurrentOrganization, url: $scope.discovery.url}, function(response) {
                pollTask(response);
            });
        };

        function pollTask(task) {
            if (task.pending) {
                Task.poll(task, function(response) {
                    setDiscoveryDetails(response);
                });
            }
            else {
                setDiscoveryDetails(task);
            }
        }
    }]
);
