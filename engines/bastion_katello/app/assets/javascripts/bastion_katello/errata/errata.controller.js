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
angular.module('Bastion.errata').controller('ErrataController',
    ['$scope', '$location', 'translate', 'Nutupane', 'Erratum', 'Task', 'Repository', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, Erratum, Task, Repository, CurrentOrganization) {
        var nutupane, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'updated',
            'sort_order': 'DESC',
            'paged': true,
            'errata_restrict_applicable': true
        };

        nutupane = $scope.nutupane = new Nutupane(Erratum, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.closeItem = function () {
            $scope.transitionTo('errata.index');
        };

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        $scope.checkIfIncrementalUpdateRunning = function () {
            var searchId, taskSearchParams, taskSearchComplete;

            taskSearchParams = {
                'type': 'all',
                "resource_type": "Organization",
                "resource_id": CurrentOrganization,
                "action_types": "Actions::Katello::ContentView::IncrementalUpdates",
                "active_only": true
            };

            taskSearchComplete = function (results) {
                $scope.incrementalUpdates = results;
                $scope.incrementalUpdateInProgress = results.length > 0;
                Task.unregisterSearch(searchId);
            };

            searchId = Task.registerSearch(taskSearchParams, taskSearchComplete);
        };

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'content_type': 'yum'}, function (response) {
            $scope.repositories = [$scope.repository];
            $scope.repositories = $scope.repositories.concat(response.results);

            if ($location.search().repositoryId) {
                $scope.repository = _.find($scope.repositories, function (repository) {
                    return repository.id === parseInt($location.search().repositoryId, 10);
                });
            }
        });

        $scope.showApplicable = true;
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

        $scope.goToNextStep = function () {
            $scope.selectedErrata = nutupane.getAllSelectedResults();
            $scope.transitionTo('errata.apply.select-content-hosts');
        };

        $scope.checkIfIncrementalUpdateRunning();
    }]
);
