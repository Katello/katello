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
 * @requires RepositoriesFilters
 *
 * @description
 *   Provides the functionality for the package repositories page.
 */
angular.module('Bastion.packages').controller('PackageRepositoriesController',
    ['$scope', '$q', 'Nutupane', 'Repository', 'Environment', 'ContentView', 'CurrentOrganization', 'RepositoriesFilters',
    function ($scope, $q, Nutupane, Repository, Environment, ContentView, CurrentOrganization, RepositoriesFilters) {
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
            params = RepositoriesFilters.modifyParamsUsingFilters(
                params, $scope.contentViewFilter, $scope.environmentFilter
            );
            repositoriesNutupane.setParams = (params);
            repositoriesNutupane.refresh();
        };
    }]
);
