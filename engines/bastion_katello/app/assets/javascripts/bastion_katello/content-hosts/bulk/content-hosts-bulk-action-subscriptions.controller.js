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
     'Organization', 'Task', 'GlobalNotification',
    function ($scope, $q, $location, HostCollection, CurrentOrganization, translate,
        Organization, Task, GlobalNotification) {

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
                    GlobalNotification.setSuccessMessage(translate('Successfully Scheduled Auto-attach.'));
                });
                promise.catch(function (errors) {
                    GlobalNotification.setErrorMessage(translate("An error occurred applying Subscriptions: ") + errors.join('; '));
                });
                promise.finally(function () {
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
    }]
);
