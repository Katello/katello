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
 * @name  Katello.systems
 *
 * @description
 *   Module for systems related functionality.
 */
angular.module('Katello.systems', ['alchemy', 'alch-templates', 'ui.compat', 'Katello.widgets']);

/**
 * @ngdoc config
 * @name  Katello.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Katello.systems').config(['$stateProvider', function($stateProvider){
    $stateProvider.state('systems', {
        views: {
            '@': {
                controller: 'SystemsController'
            }
        }
    });

    $stateProvider.state('systems.alter-content', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'views/systems/alter-content-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.alter-system-groups', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'assets/views/systems/alter-systems-group-bulk.html'
            }
        }
    });

    $stateProvider.state('systems.bulk-delete', {
        views: {
            '@': {
                controller: 'SystemsBulkActionController',
                templateUrl: 'views/systems/systems-delete-bulk.html'
            }
        }
    });
}]);
