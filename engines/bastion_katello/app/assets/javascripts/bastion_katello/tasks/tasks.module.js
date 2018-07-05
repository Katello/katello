/**
 * @ngdoc module
 * @name  Bastion.tasks
 *
 * @description
 *   Module for task related functionality.
 */
angular.module('Bastion.tasks', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.components',
    'Bastion.i18n'
]);

/**
 * @ngdoc object
 * @name Bastion.tasks.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Set up the states for tasks.
 */
angular.module('Bastion.tasks').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('tasks', {
        abstract: true,
        templateUrl: 'tasks/views/tasks.html'
    })
    .state('tasks.details', {
        url: 'katello_tasks/:taskId',
        permission: 'view_tasks',
        collapsed: true,
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details-standalone.html'
    })
    .state('task', {
        url: 'foreman_tasks/tasks/:taskId',
        controller: 'TaskDetailsController',
        permission: 'view_tasks',
        templateUrl: 'tasks/views/task-details-standalone.html'
    });

}]);
