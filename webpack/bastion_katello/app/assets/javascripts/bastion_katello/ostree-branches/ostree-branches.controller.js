/**
 * @ngdoc object
 * @name  Bastion.ostree-branches.controller:OstreeBranchesController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires OstreeBranch
 * @requires Repository
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to ostree branches for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */

angular.module('Bastion.ostree-branches').controller('OstreeBranchesController',
    ['$scope', '$location', 'translate', 'Nutupane', 'OstreeBranch', 'Repository', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, OstreeBranch, Repository, CurrentOrganization) {
        var nutupane, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'paged': true
        };

        nutupane = $scope.nutupane = new Nutupane(OstreeBranch, params);
        $scope.controllerName = 'katello_ostree_branches';
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.closeItem = function () {
            $scope.transitionTo('ostree-branches.index');
        };

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'content_type': 'ostree'}, function (response) {
            $scope.repositories = [$scope.repository];
            $scope.repositories = $scope.repositories.concat(response.results);

            if ($location.search().repositoryId) {
                $scope.repository = _.find($scope.repositories, function (repository) {
                    return repository.id === parseInt($location.search().repositoryId, 10);
                });
            }
        });

        $scope.$watch('repository', function (repository) {
            var nutupaneParams = nutupane.getParams();

            if (repository.id === 'all') {
                nutupaneParams['repository_id'] = null;
                nutupane.setParams(nutupaneParams);
            } else {
                $location.search('repositoryId', repository.id);
                nutupaneParams['repository_id'] = repository.id;
                nutupane.setParams(nutupaneParams);
            }

            if (!nutupane.table.initialLoad) {
                nutupane.refresh();
            }
        });
    }]
);
