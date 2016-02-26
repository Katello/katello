/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires Product
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsController',
    ['$scope', '$state', 'Product', 'ApiErrorHandler', function ($scope, $state, Product, ApiErrorHandler) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.product) {
            $scope.panel.loading = false;
        }

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
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
