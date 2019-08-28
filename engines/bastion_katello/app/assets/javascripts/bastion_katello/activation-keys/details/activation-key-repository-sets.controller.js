/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyRepositorySetsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires ActivationKey
 * @requires ContentOverrideHelper
 * @requires Notification
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the activation-key products action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyRepositorySetsController',
    ['$scope', 'translate', 'Nutupane', 'ActivationKey', 'ContentOverrideHelper', 'Notification', 'CurrentOrganization',
    function ($scope, translate, Nutupane, ActivationKey, ContentOverrideHelper, Notification, CurrentOrganization) {
        var params, saveContentOverride, success, error;

        params = {
            id: $scope.$stateParams.activationKeyId,
            'organization_id': CurrentOrganization
        };

        $scope.controllerName = 'katello_products';
        $scope.nutupane = new Nutupane(ActivationKey, params, 'repositorySets');
        $scope.table = $scope.nutupane.table;

        $scope.contentAccessModes = {
            contentAccessModeAll: false,
            contentAccessModeEnv: false
        };
        $scope.toggleFilters = function () {
            $scope.nutupane.table.params['content_access_mode_env'] = $scope.contentAccessModes.contentAccessModeEnv;
            $scope.nutupane.table.params['content_access_mode_all'] = $scope.contentAccessModes.contentAccessModeAll;
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
            ActivationKey.contentOverride({id: $scope.$stateParams.activationKeyId}, contentOverrides, success, error);
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
