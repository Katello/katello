/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostRepositorySetsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires HostSubscription
 * @requires ContentOverrideHelper
 * @requires Notification
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostRepositorySetsController',
    ['$scope', 'translate', 'Nutupane', 'HostSubscription', 'ContentOverrideHelper', 'Notification', 'CurrentOrganization',
    function ($scope, translate, Nutupane, HostSubscription, ContentOverrideHelper, Notification, CurrentOrganization) {
        var params, saveContentOverride, success, error;

        params = {
            id: $scope.$stateParams.hostId,
            'organization_id': CurrentOrganization,
            enabled: true,
            'full_result': true,
            'include_available_content': true
        };

        $scope.controllerName = 'katello_products';
        $scope.nutupane = new Nutupane(HostSubscription, params, 'repositorySets');
        $scope.table = $scope.nutupane.table;

        $scope.contentAccessModes = {
            contentAccessModeAll: false,
            contentAccessModeEnv: false
        };
        $scope.toggleFilters = function () {
            $scope.nutupane.table.params['content_access_mode_all'] = $scope.contentAccessModes.contentAccessModeAll;
            $scope.nutupane.table.params['content_access_mode_env'] = $scope.contentAccessModes.contentAccessModeEnv;
            $scope.nutupane.refresh();
        };

        success = function () {
            $scope.table.working = false;
            Notification.setSuccessMessage(translate('Repository Sets settings saved successfully.'));
            $scope.nutupane.refresh();
        };

        error = function (response) {
            $scope.table.working = false;
            Notification.setErrorMessage(response.data.errors);
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
