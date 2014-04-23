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
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for product or list of repositories.
 */
angular.module('Bastion.repositories').factory('Repository',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('/api/v2/repositories/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                update: { method: 'PUT' },
                sync: { method: 'POST', params: { action: 'sync' } },
                removePackages: { method: 'PUT', params: { action: 'remove_packages'}}
            }
        );

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.repositories.factory:RepositoryBulkAction
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for bulk actions on repositories.
 */
angular.module('Bastion.repositories').factory('RepositoryBulkAction',
    ['BastionResource', 'CurrentOrganization', function (BastionResource, CurrentOrganization) {

        return BastionResource('/api/v2/repositories/bulk/:action',
            {'organization_id': CurrentOrganization},
            {
                removeRepositories: {method: 'PUT', params: {action: 'destroy'}},
                syncRepositories: {method: 'POST', params: {action: 'sync'}}
            }
        );

    }]
);
