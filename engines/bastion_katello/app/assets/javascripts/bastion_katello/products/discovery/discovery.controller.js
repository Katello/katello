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
    function ($scope, $q, $timeout, $http, Task, Organization, CurrentOrganization) {
        var transformRows, setDiscoveryDetails;

        $scope.discovery = {url: ''};
        $scope.page = {loading: false};

        if (!$scope.discoveryTable) {
            $scope.discoveryTable = {rows: []};
        }

        setDiscoveryDetails = function (task) {
            $scope.discovery.pending = task.pending;

            if (!task.pending) {
                $scope.discovery.working = false;
            }

            $scope.discovery.url = task.input;
            $scope.discoveryTable.rows = transformRows(task.output);
        };

        $scope.setupSelected = function () {
            $scope.page.loading = true;
            $scope.discovery.selected = $scope.discoveryTable.getSelected();
            $scope.transitionTo('product-discovery.create').then(function () {
                $scope.page.loading = false;
            });
        };

        $scope.defaultName = function (basePath) {
            //Remove leading/trailing slash and replace rest with space
            return basePath.replace(/^\//, "").replace(/\/$/, "").replace(/\//g, ' ');
        };

        $scope.cancelDiscovery = function () {
            $scope.discovery.working = true;
            Organization.cancelRepoDiscover({id: CurrentOrganization});
        };

        transformRows = function (urls) {
            var baseUrl, toRet;
            baseUrl = $scope.discovery.url;

            toRet = _.map(urls, function (url) {
                var path = url.replace(baseUrl, "");
                return {
                    url: url,
                    path: path,
                    name: $scope.defaultName(path),
                    label: ''
                };
            });

            return _.sortBy(toRet, function (item) {
                return item.url;
            });
        };

        $scope.updateTask = function (task) {
            setDiscoveryDetails(task);
            if (!task.pending) {
                Task.unregisterSearch($scope.taskSearchId);
            }
        };

        $scope.discover = function () {
            $scope.discovery.pending = true;
            $scope.discoveryTable.rows = [];
            $scope.discoveryTable.selectAll(false);
            Organization.repoDiscover({id: CurrentOrganization, url: $scope.discovery.url}, function (task) {
                $scope.taskSearchId = Task.registerSearch({ 'type': 'task', 'task_id': task.id }, $scope.updateTask);
            });
        };

    }]
);
