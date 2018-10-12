/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires ContentHostPackage
 * @requires translate
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesController',
    ['$scope', '$timeout', '$window', 'HostPackage', 'translate', 'Nutupane', 'BastionConfig', 'Notification',
    function ($scope, $timeout, $window, HostPackage, translate, Nutupane, BastionConfig, Notification) {
        var packageActions;

        $scope.openEventInfo = function (event) {
            // when the event has label defined, it means it comes
            // from foreman-tasks
            if (event.label) {
                $scope.transitionTo('content-host.tasks.details', {taskId: event.id});
            } else {
                $scope.transitionTo('content-host.events.details', {eventId: event.id});
            }
            $scope.working = false;
        };

        $scope.errorHandler = function (response) {
            angular.forEach(response.data.errors, function (responseError) {
                Notification.setErrorMessage(responseError);
            });
            $scope.working = false;
        };

        $scope.working = false;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.packageActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.updateAll = function () {
            $scope.working = true;
            HostPackage.updateAll({id: $scope.host.id}, $scope.openEventInfo, $scope.errorHandler);
        };

        $scope.performPackageAction = function (actionType, term) {
            if ($scope.remoteExecutionByDefault) {
                $scope.performViaRemoteExecution(actionType, term, false);
            } else {
                $scope.performViaKatelloAgent(actionType, term);
            }
        };

        $scope.performViaKatelloAgent = function (actionType, term) {
            var terms = term.split(/ *, */);
            $scope.working = true;
            packageActions[actionType](terms);
        };

        $scope.performViaRemoteExecution = function(actionType, term, customize) {
            $scope.packageActionFormValues.package = term;
            $scope.packageActionFormValues.remoteAction = actionType;
            $scope.packageActionFormValues.hostIds = $scope.host.id;
            $scope.packageActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#packageActionForm').submit();
            }, 0);
        };

        packageActions = {
            packageInstall: function (termList) {
                HostPackage.install({id: $scope.host.id, packages: termList}, $scope.openEventInfo, $scope.errorHandler);
            },
            packageUpdate: function (termList) {
                HostPackage.update({id: $scope.host.id, packages: termList}, $scope.openEventInfo, $scope.errorHandler);
            },
            packageRemove: function (termList) {
                HostPackage.remove({id: $scope.host.id, packages: termList}, $scope.openEventInfo, $scope.errorHandler);
            },
            groupInstall: function (termList) {
                HostPackage.install({id: $scope.host.id, groups: termList}, $scope.openEventInfo, $scope.errorHandler);
            },
            groupRemove: function (termList) {
                HostPackage.remove({id: $scope.host.id, groups: termList}, $scope.openEventInfo, $scope.errorHandler);
            }
        };
    }
]);
