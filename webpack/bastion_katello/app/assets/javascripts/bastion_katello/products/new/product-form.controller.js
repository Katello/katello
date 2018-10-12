/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductFormController
 *
 * @requires $scope
 * @requires $q
 * @requires $uibModal
 * @requires Product
 * @requires ContentCredential
 * @requires SyncPlan
 * @requires FormUtils
 *
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductFormController',
    ['$scope', '$q', '$uibModal', 'Product', 'ContentCredential', 'SyncPlan', 'FormUtils', 'Notification',
    function ($scope, $q, $uibModal, Product, ContentCredential, SyncPlan, FormUtils, Notification) {

        function fetchContentCredentials() {
            return ContentCredential.queryUnpaged(function (contentCredentials) {
                $scope.contentCredentials = contentCredentials.results;
            });
        }

        function fetchSyncPlans() {
            return SyncPlan.queryUnpaged(function (syncPlans) {
                $scope.syncPlans = syncPlans.results;
            });
        }

        function success() {
            $scope.transitionTo('product.repositories', {productId: $scope.product.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                if ( $scope.productForm[field]) {
                    $scope.productForm[field].$setValidity('server', false);
                    $scope.productForm[field].$error.messages = errors;
                } else {
                    Notification.setErrorMessage("An error occurred while saving the Product: " + field + " " + errors);
                }
            });
        }

        $scope.product = $scope.product || new Product();

        $scope.$watch('product.name', function () {
            if ($scope.productForm.name) {
                $scope.productForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.product);
            }
        });

        $scope.save = function (product) {
            product.$save(success, error);
        };

        $q.all([fetchSyncPlans().$promise, fetchContentCredentials().$promise]).finally(function () {
            $scope.page.loading = false;
        });

        $scope.openSyncPlanModal = function () {
            $uibModal.open({
                templateUrl: 'products/new/views/new-sync-plan-modal.html',
                controller: 'NewSyncPlanModalController'
            }).result.then(function ($value) {
                fetchSyncPlans().$promise.then(function () {
                    $scope.product['sync_plan_id'] = $value.id;
                });
            });
        };
    }]
);
