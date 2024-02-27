/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyRepositorySetsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires ActivationKey
 * @requires RepositorySet
 * @requires ContentOverrideHelper
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the activation-key products action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyRepositorySetsController',
    ['$scope', 'translate', 'Nutupane', 'ActivationKey', 'RepositorySet', 'ContentOverrideHelper', 'Notification',
    function ($scope, translate, Nutupane, ActivationKey, RepositorySet, ContentOverrideHelper, Notification) {
        var params, saveContentOverride, success, error;

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Repository Sets');

        params = {
            'activation_key_id': $scope.$stateParams.activationKeyId,
            'content_access_mode_all': $scope.simpleContentAccessEnabled,
            'sort_order': 'ASC',
            'paged': true
        };
        $scope.nutupane = new Nutupane(RepositorySet, params);
        $scope.nutupane.primaryOnly = true;
        $scope.table = $scope.nutupane.table;
        $scope.repositoryTypes = {
            redhat: translate("Red Hat"),
            custom: translate("Custom")
        };

        $scope.repositoryType = {};

        $scope.contentAccessModes = {
            contentAccessModeAll: $scope.simpleContentAccessEnabled,
            contentAccessModeEnv: true
        };

        $scope.selectRepositoryType = function () {
            delete $scope.nutupane.table.params['repository_type'];
            if (!_.isEmpty($scope.repositoryType.value)) {
                $scope.nutupane.table.params['repository_type'] = $scope.repositoryType.value;
            }
            $scope.nutupane.refresh();
        };

        $scope.toggleFilters = function () {
            $scope.nutupane.table.params['content_access_mode_env'] = $scope.contentAccessModes.contentAccessModeEnv;
            $scope.nutupane.table.params['content_access_mode_all'] = $scope.contentAccessModes.contentAccessModeAll || $scope.simpleContentAccessEnabled;
            $scope.nutupane.refresh();
        };

        $scope.toggleFilters();

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
