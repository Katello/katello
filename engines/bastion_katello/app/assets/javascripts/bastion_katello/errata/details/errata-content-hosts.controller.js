/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataContentHostsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentHost
 * @requires Environment
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the available host collection details action pane.
 */
angular.module('Bastion.errata').controller('ErrataContentHostsController',
    ['$scope', 'Nutupane', 'Host', 'Environment', 'CurrentOrganization',
    function ($scope, Nutupane, Host, Environment, CurrentOrganization) {
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.restrictInstallable = false;

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        nutupane = new Nutupane(Host, params, 'postIndex');
        nutupane.table.closeItem = function () {};
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;
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
                errataIds = _.pluck($scope.table.getSelected(), 'errata_id');
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
            $scope.$parent.numberOfContentHostsToUpdate = nutupane.table.allResultsSelectCount();
            $scope.$parent.selectedContentHosts = nutupane.getAllSelectedResults();

            if ($scope.errata && $scope.errata.id) {
                $scope.transitionTo('errata.details.apply', {errataId: $scope.errata.id});
            } else {
                $scope.transitionTo('errata.apply.confirm');
            }
        };

        $scope.checkIfIncrementalUpdateRunning();
    }
]);
