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

        return BastionResource('/katello/api/products/:id/:action', {id: '@id'}, {
            update: { method: 'PUT'},
            sync: { method: 'POST', params: { action: 'sync' }},
            updateSyncPlan: { method: 'POST', params: { action: 'sync_plan' }},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.products.factory:ProductBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on products.
 */
angular.module('Bastion.products').factory('ProductBulkAction',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/products/bulk/:action', {}, {
            removeProducts: {method: 'PUT', params: {action: 'destroy'}},
            syncProducts: {method: 'PUT', params: {action: 'sync'}},
            updateProductSyncPlan: {method: 'PUT', params: {action: 'sync_plan'}}
        });
    }]
);
