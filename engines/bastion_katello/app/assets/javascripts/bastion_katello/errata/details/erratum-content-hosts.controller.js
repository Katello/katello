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
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.restrictInstallable = false;

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        nutupane = new Nutupane(Host, params, 'postIndex');
        nutupane.masterOnly = true;
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.table = nutupane.table;
        $scope.nutupane.searchTransform = function(term) {
            var addition = '( ' + $scope.errataSearchString($scope.restrictInstallable) + ' )';
            if (angular.isDefined($scope.environmentId)) {
                addition = addition + ' and lifecycle_environment_id = ' + $scope.environmentId;
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
                errataIds = _.map($scope.table.getSelected(), 'errata_id');
            }

            searchStatements = _.map(errataIds, function(errataId) {
                return searchTerm + ' = "' + errataId + '"';
            });
            return searchStatements.join(" or ");
        };

        $scope.selectEnvironment = function (environmentId) {
            $scope.environmentId = environmentId;
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
