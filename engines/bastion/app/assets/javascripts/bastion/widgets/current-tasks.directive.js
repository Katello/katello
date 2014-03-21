/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc directive
 * @name Bastion.widgets.directive:currentTasks
 *
 * @requires $document
 * @requires CurrentUser
 * @requires Task
 *
 * @description
 *  Provides a widget showing current number of runnings tasks, popping
 *  up the table of recent tasks when clicked on.
 *
 * @example
    <span current-tasks></span>
 */
angular.module('Bastion.widgets').directive('currentTasks',
    ['$document', 'CurrentUser', 'Task',
    function ($document, CurrentUser, Task) {

        return {
            restrict: 'A',
            scope: true,
            templateUrl: 'widgets/views/current-tasks.html',

            controller: ['$scope', function ($scope) {
                // Hide the current tasks list if the user clicks outside of it
                var currentTasksMenu = angular.element('#currentTasks');
                $scope.visible = false;
                $scope.currentUser = CurrentUser;
                $scope.count = 0;

                $scope.toggleVisibility = function () {
                    $scope.visible = !$scope.visible;
                };

                $scope.updateTasks = function (tasks) {
                    $scope.count = tasks.length;
                };

                $document.bind('click', function (event) {
                    var target = angular.element(event.target);
                    if (!currentTasksMenu.find(target).length) {
                        $scope.visible = false;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    }
                });
            }],
            link: function (scope) {
                Task.registerSearch({ 'active_only': true, 'type': 'user', 'user_id': CurrentUser}, scope.updateTasks);
            }
        };
    }]);
