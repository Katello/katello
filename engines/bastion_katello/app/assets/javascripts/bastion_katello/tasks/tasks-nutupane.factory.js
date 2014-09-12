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
 * @ngdoc service
 * @name  Bastion.widgets.service:TaskNutupane
 *
 * @requires Task
 * @requires Nutupane
 *
 * @description
 *   Defines TasksNutupane factory that uses Task.registerSearch as
 *   source of data instead of the standard `query` method. This
 *   effectively creates Nutupane table that is updated by polling.
 */
angular.module('Bastion.tasks').factory('TasksNutupane',
    ['Task', 'Nutupane', function (Task, Nutupane) {
        var TasksNutupane = function () {
            var self = this;

            Nutupane.call(self, Task, {});

            self.existingTasks = {};

            self.registerSearch = function (params) {
                if (!self.searchId) {
                    self.searchId = Task.registerSearch(params, self.updateTasks);
                }
            };

            self.unregisterSearch = function () {
                if (self.searchId) {
                    Task.unregisterSearch(self.searchId);
                    self.searchId = undefined;
                }
            };

            self.load = function () {
                self.table.working = true;
            };

            self.updateTasks = function (tasks) {
                self.refreshTasks(tasks);
                self.deleteOldRows(tasks);
                self.table.working = false;
            };

            self.table.search = function () {
                self.table.resource.offset = 0;
                self.table.rows = [];
                if (!self.table.working) {
                    self.load();
                }
            };

            // Updates values for existing tasks and adds new rows
            self.refreshTasks = function (tasks) {
                // we reverse because we add new items to the top of
                // the table
                _.each(tasks.reverse(), function (task) {
                    var existingTask = self.existingTasks[task.id];
                    if (existingTask) {
                        _.each(task, function (value, key) {
                            existingTask[key] = value;
                        });
                    } else {
                        self.table.rows.unshift(task);
                        self.existingTasks[task.id] = task;
                    }
                });
            };

            // Removes rows that are no longer valid for the table
            self.deleteOldRows = function (tasks) {
                var newTaskIds = _.map(tasks, function (task) { return task.id }),
                    oldTaskIds = _.keys(self.existingTasks),
                    taskIdsToDelete = _.difference(oldTaskIds, newTaskIds),
                    rowsToDelete = [];

                _.each(taskIdsToDelete, function (id) {
                    delete self.existingTasks[id];
                });

                _.each(self.table.rows, function (row, i) {
                    if (_.contains(taskIdsToDelete, row.id)) {
                        rowsToDelete.push(i);
                    }
                });

                _.each(rowsToDelete.reverse(), function (i) {
                    self.table.rows.splice(i, 1);
                });
            };
        };
        return TasksNutupane;
    }]);

