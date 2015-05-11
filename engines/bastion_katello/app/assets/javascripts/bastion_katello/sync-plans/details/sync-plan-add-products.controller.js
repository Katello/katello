/**
 * @ngdoc object
 * @name  Bastion.sync-plans.controller:SyncPlanAddProductsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires SyncPlan
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding products to a sync plan.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanAddProductsController',
    ['$scope', '$q', '$location', 'translate', 'SyncPlan', 'Nutupane',
        function ($scope, $q, $location, translate, SyncPlan, Nutupane) {
            var productsNutupane, params;

            $scope.successMessages = [];
            $scope.errorMessages = [];

            params = {
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'full_result': true,
                'id': $scope.$stateParams.syncPlanId
            };

            productsNutupane = new Nutupane(SyncPlan, params, 'availableProducts');
            $scope.productsTable = productsNutupane.table;

            $scope.addProducts = function () {
                var data,
                    success,
                    error,
                    deferred = $q.defer(),
                    productsToAdd = _.pluck($scope.productsTable.getSelected(), 'id');

                data = {
                    "product_ids": productsToAdd
                };

                success = function (response) {
                    $scope.successMessages = [translate('Added %x products to sync plan "%y".')
                        .replace('%x', $scope.productsTable.numSelected).replace('%y', $scope.syncPlan.name)];
                    $scope.productsTable.working = false;
                    $scope.productsTable.selectAll(false);
                    productsNutupane.refresh();
                    $scope.syncPlan.$get();
                    deferred.resolve(response);
                };

                error = function (response) {
                    deferred.reject(response.data.errors);
                    $scope.errorMessages = response.data.errors.base;
                    $scope.productsTable.working = false;
                };

                $scope.productsTable.working = true;
                SyncPlan.addProducts({id: $scope.syncPlan.id}, data, success, error);
                return deferred.promise;
            };
        }]
);
