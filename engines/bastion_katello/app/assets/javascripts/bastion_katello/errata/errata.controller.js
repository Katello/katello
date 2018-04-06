/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataController
 *
 * @requires $scope
 * @requires $state
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires Erratum
 * @requires IncrementalUpdate
 * @requires Repository
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to errata for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.errata').controller('ErrataController',
    ['$scope', '$state', '$stateParams', '$location', 'translate', 'Nutupane', 'Erratum', 'IncrementalUpdate', 'Repository', 'CurrentOrganization',
    function ($scope, $state, $stateParams, $location, translate, Nutupane, Erratum, IncrementalUpdate, Repository, CurrentOrganization) {
        var nutupane, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'updated',
            'sort_order': 'DESC',
            'paged': true,
            'errata_restrict_applicable': false,
            'disableAutoLoad': true
        };
        var repoId = $stateParams.repositoryId;
        if (repoId) {
            params['repository_id'] = repoId;
        }

        nutupane = $scope.nutupane = new Nutupane(Erratum, params);
        $scope.controllerName = 'katello_errata';
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        Erratum.queryPaged({'organization_id': CurrentOrganization}, function (result) {
            $scope.errataCount = result.total;
        });

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'with_content': 'erratum'}, function (response) {
            $scope.repositories = [$scope.repository];
            $scope.repositories = $scope.repositories.concat(response.results);
            if (repoId) {
                $scope.repository = _.find($scope.repositories, function (repository) {
                    return repository.id === repoId;
                });
            }
            if ($location.search().repositoryId) {
                $scope.repository = _.find($scope.repositories, function (repository) {
                    return repository.id === parseInt($location.search().repositoryId, 10);
                });
            }
        });

        $scope.showApplicable = false;
        $scope.showInstallable = false;

        $scope.toggleFilters = function () {
            if ($scope.showInstallable === true) {
                $scope.showApplicable = true;
            }

            nutupane.table.params['errata_restrict_applicable'] = $scope.showApplicable;
            nutupane.table.params['errata_restrict_installable'] = $scope.showInstallable;
            nutupane.refresh();
        };

        $scope.$watch('repository', function (repository) {
            var nutupaneParams = nutupane.getParams();

            if (repository && repository.id === 'all') {
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

        $scope.goToNextStep = function () {
            IncrementalUpdate.setBulkErrata(nutupane.getAllSelectedResults('errata_id'));
            $state.transitionTo('apply-errata.select-content-hosts');
        };

        $scope.incrementalUpdates = IncrementalUpdate.getIncrementalUpdates();
    }]
);
