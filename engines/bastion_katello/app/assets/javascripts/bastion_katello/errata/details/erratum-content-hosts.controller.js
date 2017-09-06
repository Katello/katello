/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErratumContentHostsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires Host
 * @requires IncrementalUpdate
 * @requires Environment
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the available host collection details action pane.
 */
angular.module('Bastion.errata').controller('ErratumContentHostsController',
    ['$scope', 'Nutupane', 'Host', 'IncrementalUpdate', 'Environment', 'CurrentOrganization',
    function ($scope, Nutupane, Host, IncrementalUpdate, Environment, CurrentOrganization) {
        var nutupane, params, nutupaneParams = {
            'overrideAutoLoad': true
        };

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.restrictInstallable = false;

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        nutupane = new Nutupane(Host, params, 'postIndex', nutupaneParams);
        $scope.controllerName = 'hosts';
        nutupane.masterOnly = true;
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.table = nutupane.table;
        $scope.nutupane.searchTransform = function(term) {
            var addition, errataSearchStringAddition = $scope.errataSearchString($scope.restrictInstallable);
            if (errataSearchStringAddition) {
                addition = '( ' + errataSearchStringAddition + ' )';
            }
            if (angular.isDefined($scope.environmentFilter)) {
                addition = addition + ' and lifecycle_environment_id = ' + $scope.environmentFilter;
            }

            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }
            return term + ' and ' + addition;
        };

        Environment.queryUnpaged(function (response) {
            $scope.environments = response.results;
        });

        $scope.toggleInstallable = function () {
            nutupane.refresh();
        };

        $scope.errataSearchString = function(installable) {
            var searchTerm = installable ? 'installable_errata' : 'applicable_errata',
                searchStatements, errataIds;

            if ($scope.errata) {
                errataIds = [$scope.errata['errata_id']];
            } else {
                errataIds = IncrementalUpdate.getErrataIds();
            }

            searchStatements = _.map(errataIds, function(errataId) {
                return searchTerm + ' = "' + errataId + '"';
            });
            return searchStatements.join(" or ");
        };
        nutupane.load();

        $scope.selectEnvironment = function (environmentId) {
            $scope.environmentFilter = environmentId;
            nutupane.refresh();
        };

        $scope.goToNextStep = function () {
            IncrementalUpdate.setBulkContentHosts(nutupane.getAllSelectedResults());

            if ($scope.errata && $scope.errata.id) {
                $scope.transitionTo('erratum.apply', {errataId: $scope.errata.id});
            } else {
                $scope.transitionTo('apply-errata.confirm');
            }
        };

        $scope.incrementalUpdates = IncrementalUpdate.getIncrementalUpdates();
    }
]);
