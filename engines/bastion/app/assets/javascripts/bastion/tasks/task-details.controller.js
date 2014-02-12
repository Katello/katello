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
 * @name  Bastion.tasks.controller:TaskDetailsController
 *
 * @requires $scope
 * @requires $rootScope
 * @requires Task
 *
 * @description
 *   Provides the functionality for the details of a task.
 */
angular.module('Bastion.tasks').controller('TaskDetailsController',
    ['$scope', 'Task',
    function ($scope, Task) {
        var taskId, fromState, fromParams;

        taskId = $scope.$stateParams.taskId;

        $scope.unregisterSearch = function () {
            Task.unregisterSearch($scope.searchId);
            $scope.searchId = undefined;
        };

        $scope.updateTask = function (task) {
            $scope.task = task;
            if (!$scope.task.pending) {
                $scope.unregisterSearch();
            }
        };

        $scope.isArray = _.isArray;

        $scope.$on('$destroy', function () {
            $scope.unregisterSearch();
        });

        $scope.searchId = Task.registerSearch({ 'type': 'task', 'task_id': taskId }, $scope.updateTask);
    }
]);
