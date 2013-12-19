/**
 * Copyright 2013 Red Hat, Inc.

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
 * @name  Bastion.system-groups.factory:SystemGroup
 *
 * @requires $resource
 *
 * @description
 *   Provides a $resource for system groups.
 */
angular.module('Bastion.system-groups').factory('SystemGroup',
    ['$resource',
    function ($resource) {

    return $resource('/katello/api/system_groups/:id/:action', {id: '@id'}, {
        get: {method: 'GET', params: {fields: 'full'}},
        query: {method: 'GET', isArray: false},
        update: {method: 'PUT'},
        copy: {method: 'POST', params: {action: 'copy'}},
        systems: {method: 'GET', params: {action: 'systems'}},
        removeSystems: {method: 'PUT', isArray: true, params: {action: 'remove_systems'}},
        addSystems: {method: 'PUT', isArray: true, params: {action: 'add_systems'}}
    });
}]);
