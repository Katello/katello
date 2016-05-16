/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataDetailsRepositoriesController
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
 *   Provides the functionality for the errata details repositories page.
 */
angular.module('Bastion.packages').controller('PackageDetailsRepositoriesController',
    ['$scope', '$q', 'Nutupane', 'Repository', 'Environment', 'ContentView', 'CurrentOrganization',
    function ($scope, $q, Nutupane, Repository, Environment, ContentView, CurrentOrganization) {
        var repositoriesNutupane, environment, contentView;
        var params = {
            'rpm_id': $scope.$stateParams.packageId,
            'organization_id': CurrentOrganization
        };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.detailsTable = repositoriesNutupane.table;
        $scope.detailsTable.initialLoad = false;
        repositoriesNutupane.masterOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        environment = Environment.queryUnpaged(function (response) {
            $scope.environments = response.results;
            $scope.environmentFilter = _.findWhere($scope.environments, {library: true}).id;
        });

        contentView = ContentView.queryUnpaged(function (response) {
            $scope.contentViews = response.results;
            $scope.contentViewFilter = _.findWhere($scope.contentViews, {'default': true});
        });

        $scope.detailsTable.working = true;
        $q.all([contentView.$promise, environment.$promise]).then(function () {
            $scope.filterPackages();
            $scope.detailsTable.working = false;
        });

        $scope.filterPackages = function () {
            params['environment_id'] = $scope.environmentFilter;
            params['content_view_version_id'] = $scope.contentViewFilter;

            if ($scope.contentViewFilter) {
                params['content_view_version_id'] = _.pluck($scope.contentViewFilter.versions, 'id');
            }

            repositoriesNutupane.setParams = (params);
            repositoriesNutupane.refresh();
        };
    }]
);
