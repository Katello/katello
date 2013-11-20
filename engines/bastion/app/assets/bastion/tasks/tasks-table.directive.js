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
 * @name  Bastion.systems.controller:SystemEventDetailsController
 *
 * @requires $scope
 * @requires SystemTask
 *
 * @description
 *   Provides the functionality for the details of a system event.
 */
angular.module('Bastion.tasks').directive('tasksTable',
    ['TasksNutupane',
    function(TasksNutupane) {
        var tasksNutupane = new TasksNutupane();

        return {
            restrict: 'E',
            templateUrl: 'tasks/views/tasks-table.html',
            scope: {
                resourceId: '@',
                resourceType: '@',
                userId: '@',
                activeOnly: '@',
                detailsState: '@'
            },
            controller: ['$scope', '$state', function($scope, $state) {
                // we need to set the tasksTable before the template
                // is compiled. Therefore we're doing that in the
                // controller
                $scope.tasksNutupane = new TasksNutupane();
                $scope.tasksTable = $scope.tasksNutupane.table;

                // to be able to navigate to task details from the table
                $scope.tasksNutupane.table.gotoDetails = function(taskId) {
                    $state.go($scope.detailsState, { taskId: taskId });
                };
            }],
            link: function(scope, element, attrs) {
                scope.$watch('resourceId', function(resourceId) {
                    if(resourceId) {
                        scope.tasksNutupane.registerSearch({ 'type': 'resource',
                                                             'active_only': scope.activeOnly,
                                                             'resource_type': scope.resourceType,
                                                             'resource_id': resourceId });
                    }
                });
                scope.$watch('userId', function(userId) {
                    if(userId) {
                        scope.tasksNutupane.registerSearch({ 'type': 'user',
                                                             'active_only': scope.activeOnly,
                                                             'user_id': userId });
                    }
                });
            }
        };
    }
]);
