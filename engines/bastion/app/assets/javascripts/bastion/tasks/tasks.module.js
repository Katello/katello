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
 * @ngdoc module
 * @name  Bastion.tasks
 *
 * @description
 *   Module for task related functionality.
 */
angular.module('Bastion.tasks', [
    'ngResource',
    'ui.router',
]);

/**
 * @ngdoc object
 * @name Bastion.products.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.tasks').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('tasks', {
        abstract: true,
        templateUrl: 'tasks/views/tasks.html'
    })
    .state('tasks.index', {
        url: '/tasks',
        templateUrl: 'tasks/views/tasks-index.html'
    })
    .state('tasks.details', {
        url: '/tasks/:taskId',
        collapsed: true,
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details-standalone.html'
    });

}]);

