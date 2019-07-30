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

        function successMessage(type) {
            var messages = {
                install: translate("Successfully scheduled package installation"),
                update: translate("Successfully scheduled package update"),
                remove: translate("Successfully scheduled package removal"),
                "update all": translate("Successfully scheduled an update of all packages")
            };
            return messages[type];
        }

        function installParams() {
            var params = hostIds;
            params['content_type'] = $scope.content.contentType;
            if ($scope.content.action === "update all") {
                params['update_all'] = true;
                params.content = null;
            } else {
                params.content = $scope.content.content.split(/ *, */);
            }
            params['organization_id'] = CurrentOrganization;
            return params;
        }

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;

        $scope.packageActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.content = {
            confirm: false,
            placeholder: translate('Enter Package Name(s)...'),
            contentType: 'package'
        };

        $scope.updatePlaceholder = function (contentType) {
            if (contentType === "package") {
                $scope.content.placeholder = translate('Enter Package Name(s)...');
            } else if (contentType === "package_group") {
                $scope.content.placeholder = translate('Enter Package Group Name(s)...');
            }
        };

        $scope.confirmContentAction = function (action, actionInput) {
            $scope.content.confirm = true;
            $scope.content.action = action;
            $scope.content.actionInput = actionInput;
        };

        $scope.performContentAction = function () {
            if ($scope.remoteExecutionByDefault) {
                $scope.performViaRemoteExecution();
            } else {
                $scope.performViaKatelloAgent();
            }
        };

        $scope.performViaKatelloAgent = function (action, actionInput) {
            var success, error, params;

            if (action) {
                $scope.content.action = action;
            }

            if (actionInput) {
                $scope.content.actionInput = actionInput;
            }

            $scope.content.confirm = false;

            success = function () {
                Notification.setSuccessMessage(successMessage($scope.content.action));
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
            };

            params = installParams();
            if ($scope.content.action === "install") {
                HostBulkAction.installContent(params, success, error);
            } else if ($scope.content.action === "update") {
                HostBulkAction.updateContent(params, success, error);
            } else if ($scope.content.action === "remove") {
                HostBulkAction.removeContent(params, success, error);
            } else if ($scope.content.action === "update all") {
                HostBulkAction.updateContent(params, success, error);
            }
        };

        $scope.performViaRemoteExecution = function(action, customize) {
            var selectedHosts = hostIds;

            $scope.content.confirm = false;
            $scope.packageActionFormValues.customize = customize;

            if (!action) {
                action = $scope.content.action;
            }

            if (action === "update all") {
                action = "update";
            }

            if ($scope.content.contentType === 'package_group') {
                $scope.packageActionFormValues.remoteAction = 'group_' + action;
            } else if ($scope.content.contentType === 'package') {
                $scope.packageActionFormValues.remoteAction = 'package_' + action;
            }

            if (selectedHosts.included.ids) {
                $scope.packageActionFormValues.hostIds = selectedHosts.included.ids.join(',');
            }

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
