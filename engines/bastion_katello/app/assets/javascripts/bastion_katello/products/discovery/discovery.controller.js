/**
 * @ngdoc object
 * @name  Bastion.products.controller:DiscoveryController
 *
 * @requires $scope
 * @requires $q
 * @requires $timeout
 * @requires $http
 * @requires Notification
 * @requires Task
 * @requires Organization
 * @requires CurrentOrganization
 * @requires DiscoveryRepositories
 * @requires translate
 * @requires ContainerRegistries
 *
 * @description
 *   Provides the functionality for the repo discovery action pane.
 */
angular.module('Bastion.products').controller('DiscoveryController',
    ['$scope', '$q', '$timeout', '$http', '$filter', 'Notification', 'Task', 'Organization', 'CurrentOrganization', 'DiscoveryRepositories', 'ContainerRegistries', 'translate',
    function ($scope, $q, $timeout, $http, $filter, Notification, Task, Organization, CurrentOrganization, DiscoveryRepositories, ContainerRegistries, translate) {
        var transformRows, setDiscoveryDetails;

        $scope.discovery = {
            url: '',
            contentType: 'yum'
        };

        $scope.page = {loading: false};

        $scope.containerRegistries = ContainerRegistries.registries;
        $scope.discovery.registryType = Object.keys($scope.containerRegistries)[0];

        $scope.contentTypes = [
            {id: "yum", name: "Yum Repositories"},
            {id: "docker", name: "Container Images"}
        ];
        $scope.hideSwitcher = true;
        if (!$scope.table) {
            $scope.table = {
                rows: [],
                resource: {
                    total: 0,
                    subtotal: 0
                },
                numSelected: 0
            };
        }

        setDiscoveryDetails = function (task) {
            $scope.table.rows = transformRows(task.output);
            $scope.table.resource.total = $scope.table.rows.length;
            $scope.table.resource.subtotal = $scope.table.resource.total;
        };

        $scope.filteredRows = function (filter) {
            var rows, idx;
            angular.forEach($scope.table.rows, function (row) {
                row.unselectable = true;
            });
            rows = $filter('filter')($scope.table.rows.slice(), filter);
            angular.forEach(rows, function (row) {
                idx = $scope.table.rows.indexOf(row);
                $scope.table.rows[idx].unselectable = false;
            });
            $scope.table.getSelected();

            return (rows);
        };

        $scope.setupSelected = function () {
            var url = $scope.discovery.url;
            if ($scope.discovery.contentType === 'docker') {
                url = ContainerRegistries.createUrlFor($scope.discovery.registryType,
                                                       $scope.discovery.customRegistryUrl);
            }

            if (!_.startsWith(url, 'http')) {
                url = 'http://' + url;
            }

            $scope.page.loading = true;
            $scope.discovery.selected = $scope.table.getSelected();

            DiscoveryRepositories.setRows($scope.table.getSelected());
            DiscoveryRepositories.setRepositoryUrl(url);
            DiscoveryRepositories.setUpstreamUsername($scope.discovery.upstreamUsername);
            DiscoveryRepositories.setUpstreamPassword($scope.discovery.upstreamPassword);

            $scope.transitionTo('product-discovery.create').then(function () {
                $scope.page.loading = false;
            });
        };

        $scope.defaultName = function (basePath) {
            //Remove leading/trailing slash and replace rest with space
            return basePath.replace(/^\//, "").replace(/\/$/, "").replace(/\//g, ' ');
        };

        $scope.cancelDiscovery = function () {
            $scope.discovery.working = false;
            Task.unregisterSearch($scope.taskSearchId);
            Organization.cancelRepoDiscover({id: CurrentOrganization});
        };

        transformRows = function (urls) {
            var baseUrl, toRet;
            baseUrl = $scope.discovery.url;

            toRet = _.map(urls, function (url) {
                var params, urlPath, baseUrlPath, replaceWith = '';

                params = {
                    url: $scope.discovery.url,
                    label: '',
                    contentType: $scope.discovery.contentType,
                    repositoryUrl: url
                };
                if ($scope.discovery.contentType === 'yum') {
                    urlPath = new URL(url).pathname;
                    baseUrlPath = new URL(baseUrl).pathname;
                    if (baseUrlPath.endsWith("/")) {
                        replaceWith = '/';
                    }
                    params.path = urlPath.replace(baseUrlPath, replaceWith);
                    params.name = $scope.defaultName(params.path);
                } else {
                    params.dockerUpstreamName = url;
                    params.path = url;
                    params.name = url;
                }
                return params;
            });

            return _.sortBy(toRet, function (item) {
                return item.url;
            });
        };

        $scope.updateTask = function (task) {
            if ($scope.discovery.working) {
                setDiscoveryDetails(task);
                if (task.state !== "running" && task.state !== "planned") {
                    $scope.discovery.working = false;
                    Task.unregisterSearch($scope.taskSearchId);
                    if (task.result === "error") {
                        Notification.setErrorMessage(translate("Discovery failed. Error: %s").replace('%s', task.humanized.errors[0]));
                    }
                }
            }
        };

        $scope.discover = function () {
            var params;

            $scope.discovery.working = true;
            $scope.table.rows = [];
            $scope.table.selectAll(false);
            params = {
                id: CurrentOrganization,
                'content_type': $scope.discovery.contentType,
                'upstream_username': $scope.discovery.upstreamUsername,
                'upstream_password': $scope.discovery.upstreamPassword,
                search: $scope.discovery.search
            };

            if ($scope.discovery.contentType === "yum") {
                params.url = $scope.discovery.url;
            } else {
                params.url = ContainerRegistries.urlFor($scope.discovery.registryType, $scope.discovery.customRegistryUrl);
            }

            Organization.repoDiscover(params, function (task) {
                // Hide pagination
                $scope.table.resource['per_page'] = false;
                $scope.taskSearchId = Task.registerSearch({ 'type': 'task', 'task_id': task.id }, $scope.updateTask);
            });
        };
    }]
);
