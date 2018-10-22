/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $uibModal
 * @requires translate
 * @requires Product
 * @requires Notification
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsController',
    ['$rootScope', '$scope', '$state', '$uibModal', 'translate', 'Product', 'Notification', 'ApiErrorHandler', function ($rootScope, $scope, $state, $uibModal, translate, Product, Notification, ApiErrorHandler) {
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
                $scope.transitionTo('products').then(function() {
                    $rootScope.$broadcast('productDelete', data.id);
                });
            }, function (data) {
                ApiErrorHandler.handleDELETERequestErrors(data, $scope);
            });
        };

        $scope.syncProduct = function () {
            Product.sync({id: $scope.product.id}, function (task) {
                $state.go('product.tasks.details', {taskId: task.id});
            },
            function (response) {
                angular.forEach(response.data.errors, function (error) {
                    Notification.setErrorMessage(error);
                });
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
                Notification.setSuccessMessage(translate('Sync Plan created and assigned to product.'));
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
