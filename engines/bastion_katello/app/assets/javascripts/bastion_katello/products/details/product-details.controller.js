/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $uibModal
 * @requires translate
 * @requires Product
 * @requires GlobalNotification
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsController',
    ['$scope', '$state', '$uibModal', 'translate', 'Product', 'GlobalNotification', 'ApiErrorHandler', function ($scope, $state, $uibModal, translate, Product, GlobalNotification, ApiErrorHandler) {
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

        $scope.updateProduct = function () {
            function success() {
                GlobalNotification.setSuccessMessage(translate('Sync Plan created and assigned to product.'));
            }

            function error(response) {
                ApiErrorHandler.handlePUTRequestErrors(response, $scope);
            }

            $scope.product.$update(success, error);
        };

        $scope.openSyncPlanModal = function () {
            $uibModal.open({
                templateUrl: 'products/new/views/new-sync-plan-modal.html',
                controller: 'NewSyncPlanModalController'
            }).result.then(function ($value) {
                $scope.product['sync_plan_id'] = $value.id;
                $scope.updateProduct();
            });
        };
    }]
);
