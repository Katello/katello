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

        return BastionResource('katello/api/v2/organizations/:organizationId/sync_plans/:id/:action',
            {id: '@id', organizationId: CurrentOrganization}, {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: { method: 'PUT' },
                sync: { method: 'PUT', params: {action: 'sync'}},
                addProducts: {method: 'PUT', params: {action: 'add_products'}},
                removeProducts: {method: 'PUT', params: {action: 'remove_products'}}
            }
        );

    }]
);
