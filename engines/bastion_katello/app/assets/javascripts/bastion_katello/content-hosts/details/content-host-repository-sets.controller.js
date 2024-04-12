/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostRepositorySetsController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires HostSubscription
 * @requires RepositorySet
 * @requires ContentOverrideHelper
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostRepositorySetsController',
    ['$scope', 'translate', 'Nutupane', 'HostSubscription', 'RepositorySet', 'ContentOverrideHelper', 'Notification',
    function ($scope, translate, Nutupane, HostSubscription, RepositorySet, ContentOverrideHelper, Notification) {
        var params, saveContentOverride, success, error;

        params = {
            'host_id': $scope.$stateParams.hostId,
            'content_access_mode_all': true,
            'sort_order': 'ASC',
            'paged': true
        };

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Products');

        $scope.nutupane = new Nutupane(RepositorySet, params);
        $scope.table = $scope.nutupane.table;
        $scope.nutupane.primaryOnly = true;

        $scope.contentAccessModes = {
            contentAccessModeAll: true,
            contentAccessModeEnv: false
        };
        $scope.toggleFilters = function () {
            $scope.nutupane.table.params['content_access_mode_all'] = true;
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
