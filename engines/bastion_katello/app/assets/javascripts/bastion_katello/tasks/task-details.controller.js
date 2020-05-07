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
    ['$scope', '$rootScope', 'Task',
    function ($scope, $rootScope, Task) {
        var taskId;

        taskId = $scope.$stateParams.taskId;

        $scope.unregisterSearch = function () {
            Task.unregisterSearch($scope.searchId);
            $scope.searchId = undefined;
        };

        $scope.updateTask = function (task) {
            $scope.task = task;
            if (!$scope.task.pending) {
                $rootScope.$broadcast('TaskFinished', $scope.task);
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
