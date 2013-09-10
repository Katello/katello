/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.systems.controller:SystemPackagesController
 *
 * @requires $scope
 * @requires SystemPackage
 * @requires SystemTask
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the system packages list and actions.
 */
angular.module('Bastion.systems').controller('SystemPackagesController',
    ['$scope', 'SystemPackage', 'SystemTask', 'i18nFilter', 'Nutupane',
    function($scope, SystemPackage, SystemTask, i18nFilter, Nutupane) {
        var packagesNutupane, packageActions, openEventInfo;

        openEventInfo = function(event) {
            $scope.transitionTo('systems.details.events.details', {eventId: event.id});
        };

        $scope.packageAction = {actionType: 'packageInstall'}; //default to packageInstall

        $scope.updateAll = function(){
            SystemPackage.updateAll({uuid: $scope.system.uuid}, openEventInfo);
        };

        $scope.performPackageAction = function(){
            var action, terms;
            action = $scope.packageAction.actionType;
            terms = $scope.packageAction.term.split(/ *, */);
            packageActions[action](terms);
        };

        packageActions = {
            packageInstall: function(termList) {
                SystemPackage.install({uuid: $scope.system.uuid, packages: termList}, openEventInfo);
            },
            packageUpdate: function(termList) {
                SystemPackage.update({uuid: $scope.system.uuid, packages: termList}, openEventInfo);
            },
            packageRemove: function(termList) {
                SystemPackage.remove({uuid: $scope.system.uuid, packages: termList}, openEventInfo);
            },
            groupInstall: function(termList) {
                SystemPackage.install({uuid: $scope.system.uuid, groups: termList}, openEventInfo);
            },
            groupRemove: function(termList) {
                SystemPackage.remove({uuid: $scope.system.uuid, groups: termList}, openEventInfo);
            }
        };

        packagesNutupane = new Nutupane(SystemPackage, { 'id': $scope.$stateParams.systemId }, 'get');
        $scope.currentPackagesTable = packagesNutupane.table;
        $scope.currentPackagesTable.openEventInfo = openEventInfo;
        $scope.currentPackagesTable.system = $scope.system;

        $scope.currentPackagesTable.taskFailed = function(task){
          return task === undefined || task.failed || task['affected_units'] === 0;
        };

        $scope.currentPackagesTable.removePackage = function(pkg) {
            SystemPackage.remove({
                uuid: $scope.system.uuid,
                packages:[{name: pkg.name, version: pkg.version,
                           arch: pkg.arch, release: pkg.release}]},
                function(scheduledTask){
                    pkg.removeTask = scheduledTask;
                    SystemTask.poll(scheduledTask, function(polledTask){
                        pkg.removeTask = polledTask;
                    });
                },
                function(data){
                    var message = i18nFilter("Error starting task ");
                    if (data.data.displayMessage) {
                        message += ":" + data.data.displayMessage;
                    }
                    pkg.removeTask = {'human_readable_result':message, failed: true};
                });
        };
    }
]);
