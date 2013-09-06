/**
 * Copyright 2013 Red Hat, Inc.
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
    ['$scope', '$state', 'Product', function($scope, $state, Product) {

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function() {
            $scope.panel.loading = false;
        });

        $scope.transitionTo = function(state) {
            if ($scope.product && $scope.product.hasOwnProperty("id")) {
                $state.transitionTo(state, {productId: $scope.product["id"]});
            }
        };

        $scope.isState = function (stateName) {
            return $state.includes(stateName);
        };

        $scope.removeProduct = function(product) {
            var id = product.id;

            product.$delete(function() {
                $scope.table.removeRow(id);
                $state.transitionTo('products.index');
            });
        };
    }]
);
