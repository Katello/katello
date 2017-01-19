/**
 * @ngdoc object
 * @name  Bastion.products.controller:DiscoveryController
 *
 * @requires $scope
 * @requires $q
 * @requires $timeout
 * @requires $http
 * @requires Task
 * @requires Organization
 * @requires CurrentOrganization
 * @requires DiscoveryRepositories
 * @requires translate
 *
 * @description
 *   Provides the functionality for the repo discovery action pane.
 */
angular.module('Bastion.products').controller('DiscoveryController',
    ['$scope', '$q', '$timeout', '$http', 'Task', 'Organization', 'CurrentOrganization', 'DiscoveryRepositories', 'translate',
    function ($scope, $q, $timeout, $http, Task, Organization, CurrentOrganization, DiscoveryRepositories, translate) {
        var transformRows, setDiscoveryDetails;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.discovery = {
            url: '',
            contentType: 'yum'
        };

        $scope.page = {loading: false};

        $scope.contentTypes = [
            {id: "yum", name: "Yum Repositories"},
            {id: "docker", name: "Docker Images"}
        ];

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

        $scope.setupSelected = function () {
            var url;

            if (!_.startsWith($scope.discovery.url, 'http')) {
                url = 'http://' + $scope.discovery.url;
            } else {
                url = $scope.discovery.url;
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
                var params;

                params = {
                    url: $scope.discovery.url,
                    label: '',
                    contentType: $scope.discovery.contentType
                };
                if ($scope.discovery.contentType === 'yum') {
                    params.path = url.replace(baseUrl, "");
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
                        $scope.errorMessages = [translate("Discovery failed. Error: %s").replace('%s', task.humanized.errors[0])];
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
                id: CurrentOrganization, url: $scope.discovery.url,
                'content_type': $scope.discovery.contentType,
                'upstream_username': $scope.discovery.upstreamUsername,
                'upstream_password': $scope.discovery.upstreamPassword
            };
            $scope.successMessages = [];
            $scope.errorMessages = [];
            Organization.repoDiscover(params, function (task) {
                $scope.taskSearchId = Task.registerSearch({ 'type': 'task', 'task_id': task.id }, $scope.updateTask);
            });
        };
    }]
);
