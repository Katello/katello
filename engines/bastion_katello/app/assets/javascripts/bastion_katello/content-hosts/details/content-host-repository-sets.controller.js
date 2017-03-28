/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostRepositorySetsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires HostSubscription
 * @requires ContentOverrideHelper
 * @requires GlobalNotification
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostRepositorySetsController',
    ['$scope', 'translate', 'Nutupane', 'HostSubscription', 'ContentOverrideHelper', 'GlobalNotification', 'CurrentOrganization',
    function ($scope, translate, Nutupane, HostSubscription, ContentOverrideHelper, GlobalNotification, CurrentOrganization) {
        var nutupane, params, saveContentOverride, success, error;

        params = {
            id: $scope.$stateParams.hostId,
            'organization_id': CurrentOrganization,
            enabled: true,
            'full_result': true,
            'include_available_content': true
        };

        $scope.controllerName = 'katello_products';
        nutupane = new Nutupane(HostSubscription, params, 'repositorySets');
        $scope.table = nutupane.table;

        success = function () {
            $scope.table.working = false;
            GlobalNotification.setSuccessMessage(translate('Repository Sets settings saved successfully.'));
            nutupane.refresh();
        };

        error = function (response) {
            $scope.table.working = false;
            GlobalNotification.setErrorMessage(response.data.errors);
        };

        saveContentOverride = function (contentOverrides) {
            $scope.table.working = true;
            HostSubscription.contentOverride({id: $scope.$stateParams.hostId}, contentOverrides, success, error);
        };

        $scope.overrideToEnabled = function () {
            var contentOverrides = ContentOverrideHelper.getEnabledContentOverrides($scope.table.getSelected());
            saveContentOverride(contentOverrides);
        };

        $scope.overrideToDisabled = function () {
            var contentOverrides = ContentOverrideHelper.getDisabledContentOverrides($scope.table.getSelected());
            saveContentOverride(contentOverrides);
        };

        $scope.resetToDefault = function () {
            var contentOverrides = ContentOverrideHelper.getDefaultContentOverrides($scope.table.getSelected());
            saveContentOverride(contentOverrides);
        };
    }]
);
