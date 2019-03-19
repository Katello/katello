/**
 * @ngdoc directive
 * @name Bastion.components.directive:currentTasks
 *
 * @requires $document
 * @requires authorizationService
 * @requires Task
 *
 * @description
 *  Provides a widget showing current number of runnings tasks, popping
 *  up the table of recent tasks when clicked on.
 *
 * @example
    <span current-tasks></span>
 */
angular.module('Bastion.components').directive('currentTasks',
    ['$document', 'authorizationService', 'Task',
    function ($document, authorizationService, Task) {

        return {
            restrict: 'A',
            scope: true,
            templateUrl: 'components/views/current-tasks.html',

            controller: ['$scope', function ($scope) {
                // Hide the current tasks list if the user clicks outside of it
                var currentTasksMenu = angular.element('#currentTasks');
                $scope.visible = false;
                $scope.currentUser = authorizationService.getCurrentUser();
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
                var searchParams = {'active_only': true, 'type': 'user', 'user_id': authorizationService.getCurrentUser().id};
                Task.registerSearch(searchParams, scope.updateTasks);
            }
        };
    }]);
