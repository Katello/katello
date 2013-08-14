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
 **/

/**
 * @ngdoc service
 * @name  Katello.systems.factory:System
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system or list of systems.
 */
angular.module('Bastion.systems').factory('System',
    ['$resource', 'Routes',
    function($resource, Routes) {
        return $resource(Routes.apiSystemsPath() + '/:id/:action', {id: '@uuid'}, {
            update: {method: 'PUT'},
            query: {method: 'GET', isArray: false},
            releaseVersions: {method: 'GET', params: {action: 'releases'}}
        });
    }]
);

/**
 * @ngdoc service
 * @name  Katello.systems.factory:SystemSubscriptions
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system subscriptions.
 */
angular.module('Bastion.systems').factory('SystemSubscriptions',
    ['$resource', 'Routes',
        function($resource, Routes) {
            return $resource(Routes.apiSystemsPath() + '/:id/subscriptions', {id: '@uuid'}, {
                query: {method: 'GET', isArray: false, params: {paged: true}}
            });
        }]
);
