/**
 Copyright 2013 Red Hat, Inc.

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
 * @name  Bastion.systems
 *
 * @description
 *   Module for systems related functionality.
 */
angular.module('Bastion.systems', ['ngResource', 'alchemy', 'alch-templates', 'ui.compat', 'Bastion.widgets']);

/**
 * @ngdoc object
 * @name Bastion.systems.config
 *
 * @requires $stateProvider
 * @requires $urlRouterProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.systems').config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $stateProvider.state('systems', {
        abstract: true,
        controller: 'SystemsController',
        views: {
            'sub-header': {
                templateUrl: 'systems/views/systems-sub-header.html'
            },
            '@': {
                templateUrl: 'systems/views/systems-table.html'
            }
        }
    });

    $stateProvider.state('systems.index', {
        url: '/index'
    });

    $stateProvider.state('systems.details', {
        url: '/system/:systemId',
        views: {
            'action-panel': {
                controller: 'SystemDetailsController',
                templateUrl: 'systems/views/system-details.html'
            }
        }
    });

    $stateProvider.state('systems.alter-content', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/alter-content-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.alter-system-groups', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/alter-systems-group-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.bulk-delete', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/systems-delete-bulk.html'
            }
        }
    });

    // Default state URL
    $urlRouterProvider.otherwise("/index");
}]);

angular.module('Bastion.systems').run(['$rootScope', '$state', '$stateParams',
    function ($rootScope, $state, $stateParams) {
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
    }
]);
