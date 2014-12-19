/**
 Copyright 2014 Red Hat, Inc.

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
 * @ngdoc factory
 * @name  Bastion.sync-plans.factory:SyncPlan
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for product or list of repositories.
 */
angular.module('Bastion.sync-plans').factory('SyncPlan',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('/katello/api/v2/organizations/:organizationId/sync_plans/:id/:action',
            {id: '@id', organizationId: CurrentOrganization}, {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: { method: 'PUT' },
                availableProducts: {method: 'GET', params: {action: 'available_products'}},
                addProducts: {method: 'PUT', params: {action: 'add_products'}},
                removeProducts: {method: 'PUT', params: {action: 'remove_products'}},
                products: {method: 'GET', transformResponse: function (data) {
                    var syncPlan = angular.fromJson(data);
                    return {results: syncPlan.products};
                }}
            }
        );

    }]
);
