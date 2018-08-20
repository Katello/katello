/**
 * @ngdoc object
 * @name  Bastion.packages.controller:PackageRepositoriesController
 *
 * @requires $scope
 * @requires $q
 * @requires Nutupane
 * @requires Repository
 * @requires Environment
 * @requires ContentView
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the package repositories page.
 */
angular.module('Bastion.packages').controller('PackageRepositoriesController',
    ['$scope', '$q', 'Nutupane', 'Repository', 'Environment', 'ContentView', 'CurrentOrganization',
    function ($scope, $q, Nutupane, Repository, Environment, ContentView, CurrentOrganization) {
        var repositoriesNutupane, environment, contentView;
        var params = {
            'rpm_id': $scope.$stateParams.packageId,
            'organization_id': CurrentOrganization
        };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.controllerName = 'katello_repositories';
        $scope.table = repositoriesNutupane.table;
        $scope.table.initialLoad = false;
        repositoriesNutupane.masterOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        environment = Environment.queryUnpaged(function (response) {
            $scope.environments = response.results;
            $scope.environmentFilter = _.find($scope.environments, {library: true}).id;
        });

        contentView = ContentView.queryUnpaged(function (response) {
            $scope.contentViews = response.results;
            _.each($scope.contentViews, function(cv) {
                cv['environment_ids'] = _.map(cv.environments, "id");
            });
            $scope.contentViewFilter = _.find($scope.contentViews, {'default': true});
        });

        $scope.table.working = true;
        $q.all([contentView.$promise, environment.$promise]).then(function () {
            $scope.filterPackages();
            $scope.table.working = false;
        });

        $scope.filterPackages = function () {
            var foundVersion, env;
            if ($scope.contentViewFilter) {
                if ($scope.environmentFilter) {

                    foundVersion = _.find($scope.contentViewFilter.versions, function(version) {
                        // Find the version belonging to the environment specified by the enviroment filter
                        env = _.find(version.environment_ids, function(envId) {
                            return envId === $scope.environmentFilter;
                        });

                        return !angular.isUndefined(env);
                    });

                    if (!angular.isUndefined(foundVersion)) {
                        $scope.setContentViewFilter(foundVersion.id);
                    }

                } else {
                    $scope.setContentViewFilter($scope.contentViewFilter.id, 'content_view_version');
                }
            } else {
                $scope.clearContentViewFilter();
            }

            if ($scope.environmentFilter) {
                params['environment_id'] = $scope.environmentFilter;
            } else {
                delete params['environment_id'];
                params['available_for'] = 'content_view_version';
            }

            repositoriesNutupane.setParams = (params);
            repositoriesNutupane.refresh();
        };

        $scope.setContentViewFilter = function(selectedId, keyName) {
            if (keyName && keyName === 'content_view_version') {
                params['content_view_id'] = selectedId;
                params['available_for'] = keyName;
                delete params['content_view_version_id'];
            } else {
                params['content_view_version_id'] = selectedId;
                delete params['content_view_id'];
                delete params['available_for'];
            }
        };

        $scope.clearContentViewFilter = function () {
            delete params['content_view_version_id'];
            delete params['content_view_id'];
            delete params['available_for'];
        };
    }]
);
