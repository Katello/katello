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
 * @name  Katello.systems.factory:SystemPackage
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for the system packages of a single system
 */
angular.module('Bastion.systems').factory('SystemPackage',
    ['$resource', 'Routes',
    function($resource, Routes) {
        return $resource(Routes.apiSystemsPath() + '/:id/packages/:action', {id: '@uuid'}, {
            get: {method: 'GET', isArray: false},
            remove: {method: 'PUT', params: {action: 'remove'}},
            install: {method: 'PUT', params: {action: 'install'}},
            update: {method: 'PUT', params: {action: 'upgrade'}},
            updateAll: {method: 'PUT', params: {action: 'upgrade_all'}}
        });
    }]
);
