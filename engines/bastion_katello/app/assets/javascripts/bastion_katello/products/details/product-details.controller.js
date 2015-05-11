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
