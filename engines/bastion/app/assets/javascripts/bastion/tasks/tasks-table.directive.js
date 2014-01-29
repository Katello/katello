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
 * @ngdoc directive
 * @name  Bastion.tasks.directive:tasksTable
 *
 * @requires $scope
 * @requires TasksNutupane
 *
 * @description
 *   Directive to show list of tasks for given resource/user using TasksNutupane.
 *   The basic conditions used for searching the tasks are provided in
 *   the attributes.
 *
 * @param {string} resourceType The type of resource that the tasks
 *   should be shown for, e.g. 'Katello::Repository'
 * @param {string} resourceId The id of resource that the tasks should
 *   be shown for (in case resourceType is specified)
 * @param {string} userId The id of user that the tasks should
 *   be shown for
 * @param {boolean} activeOnly Reduce the list of tasks only for active
 * @param {boolean} all Don't apply any implicit search params
 * @param {string} detailsState What state should be transitioned to
 *   for showing details of the task
 * @param {string} knownContext What parts of humanized task inputs
 *   can be skipped because are obvious from the context the table is in
 * @example
 *   <pre>
        <div tasks-table  details-state="products.details.tasks.details"
                          known-context="product,organization"
                          resource-type="Katello::Product"
                          resource-id="{{ product.id }}"/>
     </pre>
 */
angular.module('Bastion.tasks').directive('tasksTable',
    ['TasksNutupane',
    function (TasksNutupane) {
        return {
            restrict: 'A',
            templateUrl: function (element, attrs) {
                if (attrs.templateUrl) {
                    return attrs.templateUrl;
                } else {
                    return 'tasks/views/tasks-table.html';
                }
            },
            scope: {
                resourceId: '@',
                resourceType: '@',
                userId: '@',
                activeOnly: '@',
                all: '@',
                detailsState: '@',
                knownContext: '@'
            },
            controller: ['$scope', '$state', function ($scope, $state) {
                // we need to set the tasksTable before the template
                // is compiled. Therefore we're doing that in the
                // controller
                $scope.tasksNutupane = new TasksNutupane();
                $scope.tasksTable = $scope.tasksNutupane.table;

                // to be able to navigate to task details from the table
                $scope.tasksNutupane.table.gotoDetails = function (taskId) {
                    $state.go($scope.detailsState, { taskId: taskId });
                };
            }],
            link: function (scope, element) {
                scope.$watch('resourceId', function (resourceId) {
                    if (resourceId) {
                        scope.tasksNutupane.registerSearch({ 'type': 'resource',
                                                             'active_only': scope.activeOnly,
                                                             'resource_type': scope.resourceType,
                                                             'resource_id': resourceId });
                    }
                });
                scope.$watch('userId', function (userId) {
                    if (userId) {
                        scope.tasksNutupane.registerSearch({ 'type': 'user',
                                                             'active_only': scope.activeOnly,
                                                             'user_id': userId });
                    }
                });

                scope.$watch('all', function () {
                    scope.tasksNutupane.registerSearch({ 'type': 'all',
                                                         'active_only': scope.activeOnly });
                });

                element.bind('$destroy', function () {
                    scope.tasksNutupane.unregisterSearch();
                });
            }
        };
    }
]);
