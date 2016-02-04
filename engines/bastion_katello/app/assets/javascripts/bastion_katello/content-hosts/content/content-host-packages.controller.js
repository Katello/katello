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
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesController',
    ['$scope', '$timeout', '$window', 'HostPackage', 'translate', 'Nutupane', 'BastionConfig',
    function ($scope, $timeout, $window, HostPackage, translate, Nutupane, BastionConfig) {
        var packagesNutupane, packageActions, openEventInfo, errorHandler;

        openEventInfo = function (event) {
            // when the event has label defined, it means it comes
            // from foreman-tasks
            if (event.label) {
                $scope.transitionTo('content-hosts.details.tasks.details', {taskId: event.id});
            } else {
                $scope.transitionTo('content-hosts.details.events.details', {eventId: event.id});
            }
            $scope.working = false;
        };

        errorHandler = function (response) {
            $scope.errorMessages = response.data.errors;
            $scope.working = false;
        };

        $scope.packageAction = {actionType: 'packageInstall'}; //default to packageInstall
        $scope.errorMessages = [];
        $scope.working = false;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.packageActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.updateAll = function () {
            $scope.working = true;
            HostPackage.updateAll({id: $scope.host.id}, openEventInfo, errorHandler);
        };

        $scope.removeSelectedPackages = function () {
            var selected = $scope.detailsTable.getSelected();

            if (!$scope.working) {
                $scope.working = true;
                HostPackage.remove({
                    id: $scope.host.id,
                    packages: selected
                }, openEventInfo, errorHandler);
            }
        };

        $scope.performPackageAction = function () {
            if ($scope.remoteExecutionByDefault) {
                $scope.performViaRemoteExecution();
            } else {
                $scope.performViaKatelloAgent();
            }
        };

        $scope.performViaKatelloAgent = function () {
            var action, terms;
            action = $scope.packageAction.actionType;
            terms = $scope.packageAction.term.split(/ *, */);
            $scope.working = true;
            packageActions[action](terms);
        };

        $scope.performViaRemoteExecution = function(customize) {
            $scope.packageActionFormValues.package = $scope.packageAction.term;
            $scope.packageActionFormValues.remoteAction = $scope.packageAction.actionType;
            $scope.packageActionFormValues.hostIds = $scope.contentHost.host.id;
            $scope.packageActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#packageActionForm').submit();
            }, 0);
        };

        packageActions = {
            packageInstall: function (termList) {
                HostPackage.install({id: $scope.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            packageUpdate: function (termList) {
                HostPackage.update({id: $scope.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            packageRemove: function (termList) {
                HostPackage.remove({id: $scope.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            groupInstall: function (termList) {
                HostPackage.install({id: $scope.host.id, groups: termList}, openEventInfo, errorHandler);
            },
            groupRemove: function (termList) {
                HostPackage.remove({id: $scope.host.id, groups: termList}, openEventInfo, errorHandler);
            }
        };

        packagesNutupane = new Nutupane(HostPackage, {id: $scope.$stateParams.hostId});
        packagesNutupane.masterOnly = true;
        $scope.detailsTable = packagesNutupane.table;
        $scope.detailsTable.openEventInfo = openEventInfo;
        $scope.detailsTable.contentHost = $scope.contentHost;

        $scope.detailsTable.taskFailed = function (task) {
            return angular.isUndefined(task) || task.failed || task['affected_units'] === 0;
        };
    }
]);
