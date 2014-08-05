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
**/

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

            var updateTask = function (task) {
                taskMap[task.id] = task;
                if (!task.pending) {
                    unregisterSearch(task.id);
                }
                updateProgress();
                if (callback) {
                    callback(task);
                }
            },
            unregisterSearch = function (taskId) {
                if (taskSearches[taskId]) {
                    Task.unregisterSearch(taskSearches[taskId]);
                }
            },
            unregisterAll = function () {
                _.each(taskSearches, function (searchId, taskId) {
                    unregisterSearch(taskId);
                });
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
            };

            taskRepresentation.unregisterAll = unregisterAll;
            taskRepresentation.unregisterSearch = unregisterSearch;


            _.each(taskIds, function (taskId) {
                if (taskSearches[taskId] === undefined) {
                    taskSearches[taskId] = Task.registerSearch({ 'type': 'task', 'task_id': taskId }, updateTask);
                }
            });

            return taskRepresentation;
        };
        return {new: newAggregate};
    }]);
