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
 * @name  Bastion.systems.controller:SystemsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires BulkAction
 * @requires SystemGroup
 * @requires CurrentOrganization
 * @requires gettext
 * @requires Organization
 * @requires Task
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionSubscriptionsController',
    ['$scope', '$q', '$location', 'BulkAction', 'SystemGroup', 'CurrentOrganization', 'gettext',
     'Organization', 'Task',
    function ($scope, $q, $location, BulkAction, SystemGroup, CurrentOrganization, gettext,
        Organization, Task) {

        $scope.actionParams = {
            ids: []
        };

        $scope.subscription = {
            confirm: false,
            workingMode: false
        };

        $scope.performAutoAttachSubscriptions = function () {
            var success, error, deferred = $q.defer();

            $scope.subscription.confirm = false;
            $scope.subscription.workingMode = true;

            success = function (scheduledTask) {
                deferred.resolve(scheduledTask);
                $scope.subscription.autoAttachTask = scheduledTask;
                Task.poll(scheduledTask, function (polledTask) {
                    $scope.subscription.autoAttachTask = polledTask;
                    $scope.subscription.workingMode = false;
                });

                $scope.successMessages.push(gettext('Successfully Scheduled Auto-attach.'));
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.subscription.workingMode = false;
                _.each(error.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred applying Subscriptions: ") + errorMessage);
                });
            };

            Organization.autoAttachSubscriptions({}, success, error);

            return deferred.promise;
        };

        function autoAttachSubscriptionsInProgress() {
            // Check to see if an 'auto attach subscriptions' action is currently in progress.
            // If it is, poll on the associated task, until it is completed.
            Organization.query({'id': CurrentOrganization}, function (organization) {
                if (organization['owner_auto_attach_all_systems_task_id'] !== null) {

                    Task.query({'id' : organization['owner_auto_attach_all_systems_task_id']}, function (task) {
                        $scope.subscription.autoAttachTask = task;

                        if (task.pending) {
                            $scope.subscription.workingMode = true;
                            Task.poll(task, function (polledTask) {
                                $scope.subscription.autoAttachTask = polledTask;
                                $scope.subscription.workingMode = false;
                            });
                        }
                    });
                }
            });
        }
        autoAttachSubscriptionsInProgress();
    }]
);
