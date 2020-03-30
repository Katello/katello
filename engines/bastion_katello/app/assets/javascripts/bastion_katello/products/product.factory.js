/**
 * @ngdoc service
 * @name  Bastion.products.factory:Product
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for product or list of products.
 */
angular.module('Bastion.products').factory('Product',
    ['BastionResource', 'CurrentOrganization', function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/organizations/:organizationId/products/:id/:action', {id: '@id', organizationId: CurrentOrganization}, {
            update: { method: 'PUT'},
            sync: { method: 'POST', params: { action: 'sync' }},
            updateSyncPlan: { method: 'POST', params: { action: 'sync_plan' }},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);
