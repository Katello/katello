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
    ['$scope', 'Nutupane', 'ContentHost', 'Environment', 'CurrentOrganization',
    function ($scope, Nutupane, ContentHost, Environment, CurrentOrganization) {
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        if (!params['erratum_id']) {
            params['errata_ids[]'] = _.pluck($scope.table.getSelected(), 'id');
        }

        nutupane = new Nutupane(ContentHost, params, 'getPost');
        nutupane.table.closeItem = function () {};
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;

        Environment.queryUnpaged(function (response) {
            $scope.environments = response.results;
        });

        $scope.toggleInstallable = function () {
            nutupane.table.params['erratum_restrict_installable'] = $scope.errata.showInstallable;
            nutupane.refresh();
        };

        $scope.selectEnvironment = function (environmentId) {
            params['environment_id'] = environmentId;
            nutupane.setParams(params);
            nutupane.refresh();
        };

        $scope.goToNextStep = function () {
            $scope.$parent.numberOfContentHostsToUpdate = nutupane.table.allResultsSelectCount();
            $scope.$parent.selectedContentHosts = nutupane.getAllSelectedResults();

            if ($scope.errata) {
                $scope.transitionTo('errata.details.apply', {errataId: $scope.errata.id});
            } else {
                $scope.transitionTo('errata.apply.confirm');
            }
        };

        $scope.checkIfIncrementalUpdateRunning();
    }
]);
