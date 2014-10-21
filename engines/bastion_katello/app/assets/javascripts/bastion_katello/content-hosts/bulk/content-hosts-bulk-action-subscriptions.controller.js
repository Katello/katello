/**
 * Copyright 2014 Red Hat, Inc.
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
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires HostCollection
 * @requires CurrentOrganization
 * @requires translate
 * @requires Organization
 * @requires Task
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionSubscriptionsController',
    ['$scope', '$q', '$location', 'HostCollection', 'CurrentOrganization', 'translate',
     'Organization', 'Task',
    function ($scope, $q, $location, HostCollection, CurrentOrganization, translate,
        Organization, Task) {

        $scope.actionParams = {
            ids: []
        };

        $scope.subscription = {
            confirm: false,
            runningTask: null,
            taskRunnable: false,
            monitorTask: function (task) {
                var promise;
                $scope.subscription.runningTask = Task.monitorTask(task);
                promise = $scope.subscription.runningTask.promise;
                promise.then(function () {
                    $scope.state.successMessages.push(translate('Successfully Scheduled Auto-attach.'));
                });
                promise.catch(function (errors) {
                    $scope.state.errorMessages.push(translate("An error occurred applying Subscriptions: ") + errors.join('; '));
                });
                promise['finally'](function () {
                    if ($scope.subscription.runningTask.state === 'stopped') {
                        $scope.subscription.runningTask = null;
                    }
                });
            }
        };

        $scope.$watch('subscription.runningTask', function (value) {
            if (value) {
                $scope.subscription.taskRunnable = false;
            }
            if (value && $scope.subscription.runningTasksSearchId) {
                Task.unregisterSearch($scope.subscription.runningTasksSearchId);
                $scope.subscription.runningTasksSearchId = null;
            } else if (!value && !$scope.subscription.runningTasksSearchId) {
                $scope.subscription.runningTasksSearchId = watchRunningTasks();
            }
        });

        $scope.$on('$destroy', function () {
            if ($scope.subscription.runningTask) {
                $scope.subscription.runningTask.stopMonitoring();
                $scope.subscription.runningTask = null;
            }
            if ($scope.subscription.runningTasksSearchId) {
                Task.unregisterSearch($scope.subscription.runningTasksSearchId);
            }
        });

        $scope.performAutoAttachSubscriptions = function () {
            $scope.subscription.confirm = false;
            $scope.subscription.monitorTask(Organization.autoAttachSubscriptions({id: CurrentOrganization}));
        };

        function watchRunningTasks() {
            var searchParams = { 'type': 'resource',
                                 'active_only': true,
                                 'action_types': ['Actions::Katello::Organization::AutoAttachSubscriptions'],
                                 'resource_type': 'Organization',
                                 'resource_id': CurrentOrganization };
            return Task.registerSearch(searchParams, function (tasks) {
                if (tasks.length > 0) {
                    $scope.subscription.monitorTask(tasks[0]);
                } else {
                    $scope.subscription.taskRunnable = true;
                }
            });
        }
    }]
);
