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
 * @ngdoc module
 * @name  Katello
 *
 * @description
 *   Base module that defines the Katello module namespace and includes any thirdparty
 *   modules used by the application.
 */
var Katello = angular.module('Katello', ['alchemy', 'alch-templates', 'ngSanitize', 'infinite-scroll', 'ui.compat']);

/**
 * @ngdoc config
 * @name  Katello.config
 *
 * @requires $httpProvider
 * @requires $stateProvider
 *
 * @description
 *   Used for establishing application wide configuration such as adding the Rails CSRF token
 *   to every request and setting up the ui state machine.
 */
Katello.config(['$httpProvider', '$stateProvider', function($httpProvider, $stateProvider){
    $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content');

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
                templateUrl: 'views/systems/alter-systems-group-bulk.html'
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
