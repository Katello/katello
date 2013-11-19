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
 * @name  Bastion.systems.controller:SystemEventsController
 *
 * @requires $scope
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the system events list pane.
 */
angular.module('Bastion.tasks').controller('TasksController',
    ['$scope', '$state', 'Task', 'Nutupane', 'taskListProvider',
    function($scope, $state, Task,  Nutupane, taskListProvider) {
        var params, tasksNutupane;
        var systemId = 1;
        var systemUuid = $scope.$stateParams.systemId;
        params = {
            'resource_id':      systemId,
            'resource_type':    $state.current.data.resourceType,
            'type':             'resource',
        };

        var TasksNutupane = function(params) {
            var self = this;

            Nutupane.call(self, Task, {});

            self.existingTasks = {}

            self.register = function(scope) {
                scope.updateTasks = self.updateTasks;
                taskListProvider.registerScope(scope, params);
            };

            self.load = function(replace) {
                self.table.working = true;
            };

            self.updateTasks = function(tasks) {
                self.refreshTasks(tasks);
                self.deleteOldRows(tasks);
                self.table.working = false;
            };

            self.table.search = function() {
                self.table.resource.offset = 0;
                self.table.rows = [];
                if (!self.table.working) {
                    self.load();
                }
            };

            // Updates values for existing tasks and adds new rows
            self.refreshTasks = function(tasks) {
                // we reverse because we add new items to the top of
                // the table
                _.each(tasks.reverse(), function(task) {
                    var existingTask = self.existingTasks[task.uuid];
                    if(existingTask) {
                        _.each(task, function(value, key) {
                            existingTask[key] = value;
                        });
                    } else {
                        self.table.rows.unshift(task);
                        self.existingTasks[task.uuid] = task;
                    }
                });
            }

            // Removes rows that are no longer valid for the table
            self.deleteOldRows = function(tasks) {
                var newTaskUuids = _.map(tasks, function(task) { return task.uuid }),
                    oldTaskUuids = _.keys(self.existingTasks),
                    uuidsToDelete = _.difference(oldTaskUuids, newTaskUuids),
                    rowsToDelete = [];

                _.each(uuidsToDelete, function(uuid) {
                    delete self.existingTasks[uuid];
                });

                _.each(self.table.rows, function(row, i) {
                    if(_.contains(uuidsToDelete, row.uuid)) {
                        rowsToDelete.push(i);
                    };
                });

                _.each(rowsToDelete.reverse(), function(i) {
                    self.table.rows.splice(i, 1);
                });
            }

        }

        tasksNutupane = new TasksNutupane(params);
        tasksNutupane.register($scope);
        $scope.tasksTable = tasksNutupane.table;
    }
]);
