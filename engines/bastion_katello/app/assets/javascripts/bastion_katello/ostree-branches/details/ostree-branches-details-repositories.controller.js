/**
 * @ngdoc object
 * @name  Bastion.ostree-branches.controller:OstreeBranchesDetailsRepositoriesController
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
 *   Provides the functionality for the OSTree branch repositories page.
 */
angular.module('Bastion.ostree-branches').controller('OstreeBranchesDetailsRepositoriesController',
    ['$scope', '$q', 'Nutupane', 'Repository', 'Environment', 'ContentView', 'CurrentOrganization',
    function ($scope, $q, Nutupane, Repository, Environment, ContentView, CurrentOrganization) {
        var repositoriesNutupane, environment, contentView, params;
        params = {
            'ostree_branch_id': $scope.$stateParams.branchId,
            'organization_id': CurrentOrganization,
            'paged': false
        };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.detailsTable = repositoriesNutupane.table;
        $scope.detailsTable.initialLoad = false;
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

        $scope.detailsTable.working = true;
        $q.all([contentView.$promise, environment.$promise]).then(function () {
            $scope.filterBranches();
            $scope.detailsTable.working = false;
        });

        $scope.filterBranches = function () {
            params['environment_id'] = $scope.environmentFilter;
            params['content_view_version_id'] = $scope.contentViewFilter;

            if ($scope.contentViewFilter) {
                params['content_view_version_id'] = _.map($scope.contentViewFilter.versions, 'id');
            }

            repositoriesNutupane.setParams(params);
            repositoriesNutupane.refresh();
        };
    }]
);
