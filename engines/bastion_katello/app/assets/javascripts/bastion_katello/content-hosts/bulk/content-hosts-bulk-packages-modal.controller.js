/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkPackagesModalController
 *
 * @requires $scope
 * @resource $location
 * @resource $timeout
 * @resource $window
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires CurrentOrganization
 * @requires translate
 * @requires Notification
 * @requires BastionConfig
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkPackagesModalController',
    ['$scope', '$location', '$timeout', '$window', '$uibModalInstance', 'HostBulkAction', 'CurrentOrganization', 'translate', 'Notification', 'BastionConfig', 'hostIds',
    function ($scope, $location, $timeout, $window, $uibModalInstance, HostBulkAction, CurrentOrganization, translate, Notification, BastionConfig, hostIds) {

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.hostToolingEnabled = BastionConfig.hostToolingEnabled;

        $scope.packageActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.content = {
            confirm: false,
            placeholder: translate('Enter Package Name(s)...')
        };

        $scope.confirmContentAction = function (action, actionInput) {
            $scope.content.confirm = true;
            $scope.content.action = action;
            $scope.content.actionInput = actionInput;
        };

        $scope.performContentAction = function () {
            $scope.performViaRemoteExecution();
        };

        $scope.performViaRemoteExecution = function(action, customize) {
            var selectedHosts = hostIds;

            $scope.content.confirm = false;
            $scope.packageActionFormValues.customize = customize;
            $scope.allHostsSelected = selectedHosts.allResultsSelected;

            if (!action) {
                action = $scope.content.action;
            }

            if (action === "update all") {
                action = "update";
            }

            $scope.packageActionFormValues.remoteAction = 'package_' + action;

            $scope.packageActionFormValues.bulkHostIds = angular.toJson(selectedHosts);

            $timeout(function () {
                angular.element('#packageActionForm').submit();
            }, 0);
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };
    }]
);
