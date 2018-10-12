/**
* @ngdoc service
* @name  Bastion.tasks.factory:AggregateTask
*
* @requires Task
 *
* @description
*   Provides a BastionResource for aggregating multiple tasks into a task like interface.
*
*/

angular.module('Bastion.tasks').factory('AggregateTask',
    ['Task', function (Task) {

        /**
          * @param {Array} taskIds ids of tasks to be polled for
          *
          * @param {Function} callback function to reflect the
          *        changes after the task was updated.
          *        The function is called with the updated aggregated task
          */
        var newAggregate = function (taskIds, callback) {
            var taskMap = {},
                taskSearches = {},
                taskRepresentation = {
                    state: undefined,
                    result: undefined,
                    progressbar: {}
                };

            var unregisterSearch = function (taskId) {
                if (taskSearches[taskId]) {
                    Task.unregisterSearch(taskSearches[taskId]);
                }
            },
            greatestType = function () {
                var found = 'success',
                    weights = {
                        error: 3,
                        danger: 2,
                        success: 1
                    };

                _.each(taskMap, function (task) {
                    if (weights[task.progressbar.type] > weights[found]) {

                        found = task.progressbar.type;
                    }
                });
                return found;
            },
            greatestState = function () {
                var found = 'stopped',
                    weights = {
                        running: 3,
                        pending: 2,
                        stopped: 1
                    };
                _.each(taskMap, function (task) {
                    if (weights[task.state] > weights[found]) {
                        found = task.state;
                    }
                });
                return found;
            },
            greatestResult = function () {
                var found = 'success',
                    weights = {
                        error: 4,
                        warning: 3,
                        pending: 2,
                        success: 1
                    };
                _.each(taskMap, function (task) {
                    if (weights[task.result] > weights[found]) {
                        found = task.result;
                    }
                });
                return found;
            },
            updateProgress = function () {
                var total = 0;
                _.each(taskMap, function (task) {
                    total = total + task.progressbar.value;
                });
                taskRepresentation.progressbar.value = total / _.size(taskMap);
                taskRepresentation.progressbar.type = greatestType();
                taskRepresentation.state = greatestState();
                taskRepresentation.result = greatestResult();
            },
            updateTask = function (task) {
                taskMap[task.id] = task;
                if (!task.pending) {
                    unregisterSearch(task.id);
                }
                updateProgress();
                if (callback) {
                    callback(task);
                }
            },
            unregisterAll = function () {
                _.each(taskSearches, function (searchId, taskId) {
                    unregisterSearch(taskId);
                });
            };

            taskRepresentation.unregisterAll = unregisterAll;
            taskRepresentation.unregisterSearch = unregisterSearch;


            _.each(taskIds, function (taskId) {
                if (angular.isUndefined(taskSearches[taskId])) {
                    taskSearches[taskId] = Task.registerSearch({ 'type': 'task', 'task_id': taskId }, updateTask);
                }
            });

            return taskRepresentation;
        };
        return {new: newAggregate};
    }]);
