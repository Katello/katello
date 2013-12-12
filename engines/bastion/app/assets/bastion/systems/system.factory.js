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
 * @name  Bastion.systems.factory:System
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system or list of systems.
 */
angular.module('Bastion.systems').factory('System',
    ['$resource', 'Routes',
    function ($resource, Routes) {

        return $resource(Routes.apiSystemsPath() + '/:id/:action/:action2', {id: '@uuid'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            update: {method: 'PUT'},
            query: {method: 'GET', isArray: false},
            releaseVersions: {method: 'GET', params: {action: 'releases'}},
            saveSystemGroups: {method: 'POST', params: {action: 'system_groups'}},
            refreshSubscriptions: {method: 'PUT', params: {action: 'refresh_subscriptions'}},
            availableSubscriptions: {method: 'GET', params: {action: 'subscriptions', action2: 'available'}},
            tasks: {method: 'GET', params: {action: 'tasks', paged: true}}
        });

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.systems.factory:BulkAction
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for bulk actions on systems.
 */
angular.module('Bastion.systems').factory('BulkAction',
    ['$resource', 'Routes',
    function ($resource, Routes) {
        return $resource(Routes.apiSystemsPath() + '/:action', {}, {
            addSystemGroups: {method: 'PUT', params: {action: 'add_system_groups'}},
            removeSystemGroups: {method: 'PUT', params: {action: 'remove_system_groups'}},
            installContent: {method: 'PUT', params: {action: 'install_content'}},
            updateContent: {method: 'PUT', params: {action: 'update_content'}},
            removeContent: {method: 'PUT', params: {action: 'remove_content'}},
            removeSystems: {method: 'PUT', params: {action: 'destroy'}}
        });
    }]
);
