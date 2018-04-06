/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsInstalledController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostDeb
 * @requires translate
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host deb packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsInstalledController',
    ['$scope', '$timeout', '$window', 'HostDeb', 'translate', 'Nutupane', 'BastionConfig', 'Notification',
    function ($scope, $timeout, $window, HostDeb, translate, Nutupane, BastionConfig, Notification) {
        var debsNutupane;

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

        $scope.removeSelectedDebs = function () {
            var selected;

            if (!$scope.working) {
                $scope.working = true;
                selected = $scope.table.getSelected().map(function (p) {
                    return p.name;
                }).join(' ');
                $scope.performPackageAction('packageRemove', selected);
            }
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

        debsNutupane = new Nutupane(HostDeb, {id: $scope.$stateParams.hostId});
        debsNutupane.masterOnly = true;
        $scope.table = debsNutupane.table;
        $scope.table.contentHost = $scope.contentHost;
    }
]);
