/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @resource $location
 * @resource $timeout
 * @resource $window
 * @requires HostBulkAction
 * @requires CurrentOrganization
 * @requires translate
 * @requires BastionConfig
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionPackagesController',
    ['$scope', '$q', '$location', '$timeout', '$window', 'HostBulkAction', 'CurrentOrganization', 'translate', 'BastionConfig',
    function ($scope, $q, $location, $timeout, $window, HostBulkAction, CurrentOrganization, translate, BastionConfig) {

        function successMessage(type) {
            var messages = {
                install: translate("Succesfully scheduled package installation"),
                update: translate("Succesfully scheduled package update"),
                remove: translate("Succesfully scheduled package removal")
            };
            return messages[type];
        }

        function installParams() {
            var params = $scope.nutupane.getAllSelectedResults();
            params['content_type'] = $scope.content.contentType;
            params.content = $scope.content.content.split(/ *, */);
            params['organization_id'] = CurrentOrganization;
            return params;
        }

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.setState(false, [], []);
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
            var success, error, params, deferred = $q.defer();

            if (action) {
                $scope.content.action = action;
            }

            if (actionInput) {
                $scope.content.actionInput = actionInput;
            }

            $scope.content.confirm = false;
            $scope.setState(true, [], []);

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, [successMessage($scope.content.action)], []);
            };

            error = function (response) {
                $scope.setState(false, [], response.data.errors);
                deferred.reject(response.data.errors);
            };

            params = installParams();
            if ($scope.content.action === "install") {
                HostBulkAction.installContent(params, success, error);
            } else if ($scope.content.action === "update") {
                HostBulkAction.updateContent(params, success, error);
            } else if ($scope.content.action === "remove") {
                HostBulkAction.removeContent(params, success, error);
            }

            return deferred.promise;
        };

        $scope.performViaRemoteExecution = function(action, customize) {
            var selectedHosts = $scope.nutupane.getAllSelectedResults();

            $scope.content.confirm = false;
            $scope.packageActionFormValues.customize = customize;

            if (!action) {
                action = $scope.content.action;
            }

            if ($scope.content.contentType === 'package_group') {
                $scope.packageActionFormValues.remoteAction = 'group_' + action;
            } else if ($scope.content.contentType === 'package') {
                $scope.packageActionFormValues.remoteAction = 'package_' + action;
            }

            $scope.packageActionFormValues.hostIds = selectedHosts.included.ids.join(',');
            $scope.packageActionFormValues.search = selectedHosts.included.search;

            $timeout(function () {
                angular.element('#packageActionForm').submit();
            }, 0);
        };
    }]
);
