/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires ContentHostDeb
 * @requires translate
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsController',
    ['$scope', '$timeout', '$window', 'translate', 'Nutupane', 'BastionConfig', 'Notification',
    function ($scope, $timeout, $window, translate, Nutupane, BastionConfig, Notification) {
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
        $scope.packageActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.updateAll = function () {
            $scope.working = true;
            $scope.performPackageAction('packageUpdate', '');
        };

        $scope.performPackageAction = function (actionType, term) {
            $scope.performViaRemoteExecution(actionType, term, false);
        };

        $scope.performViaRemoteExecution = function (actionType, term, customize) {
            $scope.packageActionFormValues.package = term;
            $scope.packageActionFormValues.remoteAction = actionType;
            $scope.packageActionFormValues.hostIds = $scope.host.id;
            $scope.packageActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#packageActionForm').submit();
            }, 0);
        };
    }
]);
