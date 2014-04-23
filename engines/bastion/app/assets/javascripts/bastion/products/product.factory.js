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
 * @name  Bastion.products.factory:Product
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for product or list of products.
 */
angular.module('Bastion.products').factory('Product',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/api/products/:id/:action', {id: '@id'}, {
            update: { method: 'PUT'},
            sync: { method: 'POST', isArray: true, params: { action: 'sync' }},
            updateSyncPlan: { method: 'POST', params: { action: 'sync_plan' }}
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
        return BastionResource('/api/products/bulk/:action', {}, {
            removeProducts: {method: 'PUT', params: {action: 'destroy'}},
            syncProducts: {method: 'PUT', params: {action: 'sync'}},
            updateProductSyncPlan: {method: 'PUT', params: {action: 'sync_plan'}}
        });
    }]
);
