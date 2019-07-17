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

        return BastionResource('katello/api/v2/products/bulk/:action', {}, {
            removeProducts: {method: 'PUT', params: {action: 'destroy'}},
            syncProducts: {method: 'PUT', params: {action: 'sync'}},
            updateProductSyncPlan: {method: 'PUT', params: {action: 'sync_plan'}},
            updateProductHttpProxy: {method: 'PUT', params: {action: 'http_proxy'}}
        });
    }]
);
