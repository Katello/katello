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
        $scope.page = {
            error: false,
            loading: true
        };

        if ($scope.product) {
            $scope.page.loading = false;
        }

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.removeProduct = function (product) {
            product.$delete(function (data) {
                $scope.$emit('productDelete', data.id);
                $scope.transitionTo('products');
            });
        };

        $scope.syncProduct = function () {
            Product.sync({id: $scope.product.id}, function (task) {
                $state.go('product.tasks.details', {taskId: task.id});
            },
            function (response) {
                $scope.errorMessages = response.data.errors;
            });
        };

        $scope.productDeletable = function(product) {
            return $scope.getReadOnlyReason(product) === null;
        };

        $scope.getReadOnlyReason = function (product) {
            var readOnlyReason = null;

            if (product.$resolved) {
                if (product.redhat) {
                    readOnlyReason = 'redhat';
                } else if ($scope.denied('destroy_products', product)) {
                    readOnlyReason = 'permissions';
                } else if (product['published_content_view_ids'].length > 0) {
                    readOnlyReason = 'published';
                }
            }

            return readOnlyReason;
        };
    }]
);
