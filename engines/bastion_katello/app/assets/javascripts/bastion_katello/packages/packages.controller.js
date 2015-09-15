/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires Erratum
 * @requires Repository
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to errata for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.packages').controller('PackagesController',
    ['$scope', '$location', 'translate', 'Nutupane', 'Package', 'Task', 'Repository', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, Package, Task, Repository, CurrentOrganization) {
        var nutupane, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'paged': true
        };

        nutupane = $scope.nutupane = new Nutupane(Package, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.closeItem = function () {
            $scope.transitionTo('packages.index');
        };

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'content_type': 'yum'}, function (response) {
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
