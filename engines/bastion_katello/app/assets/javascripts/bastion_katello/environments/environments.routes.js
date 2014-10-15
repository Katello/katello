/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc object
 * @name Bastion.environments.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.environments').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('environments', {
        url: '/lifecycle_environments',
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentsController',
        templateUrl: 'environments/views/environments.html'
    })
    .state('environment', {
        url: '/lifecycle_environments/:environmentId',
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentController',
        templateUrl: 'environments/details/views/environment.html'
    })
    .state('environment.details', {
        url: '/details',
        permission: 'view_lifecycle_environments',
        templateUrl: 'environments/details/views/environment-details.html'
    })
    .state('environment.errata', {
        url: '/errata',
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-errata.html'
    });
}]);
