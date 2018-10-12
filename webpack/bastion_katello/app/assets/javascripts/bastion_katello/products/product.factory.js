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
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/products/:id/:action', {id: '@id'}, {
            update: { method: 'PUT'},
            sync: { method: 'POST', params: { action: 'sync' }},
            updateSyncPlan: { method: 'POST', params: { action: 'sync_plan' }},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);
