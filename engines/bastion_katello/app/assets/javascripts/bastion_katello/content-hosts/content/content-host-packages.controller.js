/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesController
 *
 * @requires $scope
 * @requires ContentHostPackage
 * @requires translate
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesController',
    ['$scope', 'HostPackage', 'translate', 'Nutupane',
    function ($scope, HostPackage, translate, Nutupane) {
        var packagesNutupane, packageActions, openEventInfo, errorHandler,
            PACKAGES_PER_PAGE = 50;

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

        $scope.updateAll = function () {
            $scope.working = true;
            HostPackage.updateAll({id: $scope.contentHost.host.id}, openEventInfo, errorHandler);
        };

        $scope.performPackageAction = function () {
            var action, terms;
            action = $scope.packageAction.actionType;
            terms = $scope.packageAction.term.split(/ *, */);
            $scope.working = true;
            packageActions[action](terms);
        };

        packageActions = {
            packageInstall: function (termList) {
                HostPackage.install({id: $scope.contentHost.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            packageUpdate: function (termList) {
                HostPackage.update({id: $scope.contentHost.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            packageRemove: function (termList) {
                HostPackage.remove({id: $scope.contentHost.host.id, packages: termList}, openEventInfo, errorHandler);
            },
            groupInstall: function (termList) {
                HostPackage.install({id: $scope.contentHost.host.id, groups: termList}, openEventInfo, errorHandler);
            },
            groupRemove: function (termList) {
                HostPackage.remove({id: $scope.contentHost.host.id, groups: termList}, openEventInfo, errorHandler);
            }
        };

        // Need to delay loading until we have host id in $stateParams in the future
        packagesNutupane = new Nutupane(HostPackage, {initialLoad: false});

        $scope.contentHost.$promise.then(function () {
            packagesNutupane.setParams({id: $scope.contentHost.host.id});
            packagesNutupane.load();
        });

        $scope.currentPackagesTable = packagesNutupane.table;
        $scope.currentPackagesTable.openEventInfo = openEventInfo;
        $scope.currentPackagesTable.contentHost = $scope.contentHost;

        $scope.currentPackagesTable.taskFailed = function (task) {
            return angular.isUndefined(task) || task.failed || task['affected_units'] === 0;
        };

        $scope.currentPackagesTable.removePackage = function (pkg) {
            if (!$scope.working) {
                $scope.working = true;
                HostPackage.remove({
                    id: $scope.contentHost.host.id,
                    packages: [{name: pkg.name, version: pkg.version,
                        arch: pkg.arch, release: pkg.release}]
                }, openEventInfo, errorHandler);
            }
        };

        $scope.currentPackagesTable.limit = PACKAGES_PER_PAGE;
        $scope.currentPackagesTable.loadMorePackages = function () {
            $scope.$evalAsync(function (scope) {
                scope.currentPackagesTable.limit = scope.currentPackagesTable.limit + PACKAGES_PER_PAGE;
            });
        };
    }
]);
