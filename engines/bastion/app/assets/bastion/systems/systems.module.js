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
angular.module('Bastion.systems', [
    'ngResource',
    'alchemy',
    'alch-templates',
    'ui.compat',
    'Bastion.widgets',
    'Bastion.subscriptions',
    'Bastion.system-groups',
]);

/**
 * @ngdoc object
 * @name Bastion.systems.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.systems').config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('systems', {
        abstract: true,
        controller: 'SystemsController',
        templateUrl: 'systems/views/systems.html'
    });

    $stateProvider.state('systems.index', {
        url: '/index',
        views: {
            'table': {
                templateUrl: 'systems/views/systems-table-full.html'
            }
        }
    });

    $stateProvider.state("systems.details", {
        abstract: true,
        url: '/system/:systemId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'systems/views/systems-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SystemDetailsController',
                templateUrl: 'systems/details/views/system-details.html'
            }
        }
    });

    $stateProvider.state('systems.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'SystemDetailsInfoController',
        templateUrl: 'systems/details/views/system-info.html'
    });

    $stateProvider.state('systems.details.subscriptions', {
        url: '/subscriptions',
        collapsed: true,
        controller: 'SystemSubscriptionsController',
        templateUrl: 'systems/details/views/system-subscriptions.html'
    });

    $stateProvider.state('systems.alter-content', {
        views: {
            'action-panel': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/alter-content-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.alter-system-groups', {
        views: {
            'action-panel': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/alter-systems-group-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.bulk-delete', {
        views: {
            'action-panel': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'systems/views/systems-delete-bulk.html'
            }
        }
    });
}]);

angular.module('Bastion.systems').run(['$rootScope', '$state', '$stateParams',
    function ($rootScope, $state, $stateParams) {
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
    }
]);
