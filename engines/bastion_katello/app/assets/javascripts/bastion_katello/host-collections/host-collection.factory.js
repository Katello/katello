/**
 * Copyright 2014 Red Hat, Inc.

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
 * @ngdoc factory
 * @name  Bastion.host-collections.factory:HostCollection
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for host collections.
 */
angular.module('Bastion.host-collections').factory('HostCollection',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/host_collections/:id/:action', {id: '@id'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            update: {method: 'PUT'},
            copy: {method: 'POST', params: {action: 'copy'}},
            contentHosts: {method: 'GET', params: {action: 'systems'}},
            removeContentHosts: {method: 'PUT', params: {action: 'remove_systems'}},
            addContentHosts: {method: 'PUT', params: {action: 'add_systems'}}
        });

    }]
);
