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
 * @ngdoc service
 * @name  Bastion.repositories.factory:Repository
 *
 * @requires $resource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a $resource for product or list of repositories.
 */
angular.module('Bastion.repositories').factory('Repository',
    ['$resource', 'CurrentOrganization',
    function ($resource, CurrentOrganization) {

        return $resource('/katello/api/repositories/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                update: { method: 'PUT', params: { id: '@label', product_id: '@product.label' } },
                query: { method: 'GET' },
                sync: {method: 'POST', params: {action: 'sync'}}
            }
        );

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.repositories.factory:RepositoryBulkAction
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for bulk actions on repositories.
 */
angular.module('Bastion.repositories').factory('RepositoryBulkAction',
    ['$resource', 'CurrentOrganization', function ($resource, CurrentOrganization) {
        return $resource('/katello/api/repositories/bulk/:action',
            {'organization_id': CurrentOrganization},
            {
                removeRepositories: {method: 'PUT', params: {action: 'destroy'}},
                syncRepositories: {method: 'POST', params: {action: 'sync'}}
            }
        );
    }]
);
