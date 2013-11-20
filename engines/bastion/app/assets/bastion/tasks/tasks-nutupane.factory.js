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
 * @ngdoc service
 * @name  Bastion.widgets.service:Nutupane
 *
 * @requires $location
 * @requires $q
 * @requires $timeout
 *
 * @description
 *   Defines the Nutupane factory for adding common functionality to the Nutupane master-detail
 *   pattern.  Note that the API Nutupane uses must provide a response of the following structure:
 *
 *   {
 *      offset: 25,
 *      subtotal: 50,
 *      total: 100,
 *      results: [...]
 *   }
 *
 * @example
 *   <pre>
       angular.module('example').controller('ExampleController',
           ['Nutupane', function(Nutupane)) {
               var nutupane                = new Nutupane(ExampleResource);
               $scope.table                = nutupane.table;
           }]
       );
    </pre>
 */
angular.module('Bastion.tasks').factory('TasksNutupane',
    ['Task', 'Nutupane', function(Task, Nutupane) {
        var TasksNutupane = function() {
            var self = this;

            Nutupane.call(self, Task, {});

            self.existingTasks = {}

            self.registerSearch = function(params) {
                if(!self.searchId) {
                    self.searchId = Task.registerSearch(params, self.updateTasks);
                }
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

            self.updateProgressbar = function(task) {
                var type = task.result == 'error' ? 'danger' : 'success';
                task.progressbar = { value: task.progress * 100, type: type }
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
                    self.updateProgressbar(self.existingTasks[task.uuid]);
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
        return TasksNutupane;
    }]);

