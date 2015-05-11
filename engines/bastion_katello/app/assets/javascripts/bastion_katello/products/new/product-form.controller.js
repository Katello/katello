/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductFormController
 *
 * @requires $scope
 * @requires $q
 * @requires Product
 * @requires GPGKey
 * @requires SyncPlan
 * @requires FormUtils
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductFormController',
    ['$scope', '$q', 'Product', 'GPGKey', 'SyncPlan', 'FormUtils',
    function ($scope, $q, Product, GPGKey, SyncPlan, FormUtils) {

        function fetchGpgKeys() {
            return GPGKey.queryUnpaged(function (gpgKeys) {
                $scope.gpgKeys = gpgKeys.results;
            });
        }

        function fetchSyncPlans() {
            return SyncPlan.queryUnpaged(function (syncPlans) {
                $scope.syncPlans = syncPlans.results;
            });
        }

        function success(response) {
            $scope.productTable.addRow(response);
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.product.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.productForm[field].$setValidity('server', false);
                $scope.productForm[field].$error.messages = errors;
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

        $q.all([fetchSyncPlans().$promise, fetchGpgKeys().$promise]).finally(function () {
            $scope.panel.loading = false;
        });
    }]
);
