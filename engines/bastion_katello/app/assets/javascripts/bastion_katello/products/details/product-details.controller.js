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
 */

/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires Product
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsController',
    ['$scope', '$state', 'Product', function ($scope, $state, Product) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.product) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.panel.loading = false;
        });

        $scope.removeProduct = function (product) {
            var id = product.id;

            product.$delete(function (data) {
                $scope.removeRow(id);
                $scope.$emit('productDelete', data.id);
                $scope.transitionTo('products.index');
            });
        };

        $scope.getReadOnlyReason = function (product) {
            var readOnlyReason = null;

            if (product.$resolved) {
                if ($scope.denied('destroy_products', product)) {
                    readOnlyReason = 'permissions';
                } else if (product['published_content_view_ids'].length > 0) {
                    readOnlyReason = 'published';
                } else if (product.redhat) {
                    readOnlyReason = 'redhat';
                }
            }
            
            return readOnlyReason;
        };
    }]
);
