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
            $scope.contentViewFilter = _.find($scope.contentViews, {'default': true});
        });

        $scope.table.working = true;
        $q.all([contentView.$promise, environment.$promise]).then(function () {
            $scope.filterPackages();
            $scope.table.working = false;
        });

        $scope.filterPackages = function () {
            params['environment_id'] = $scope.environmentFilter;
            params['content_view_version_id'] = $scope.contentViewFilter;

            if ($scope.contentViewFilter) {
                params['content_view_version_id'] = _.map($scope.contentViewFilter.versions, 'id');
            }

            repositoriesNutupane.setParams = (params);
            repositoriesNutupane.refresh();
        };
    }]
);
