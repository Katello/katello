/**
 * @ngdoc object
 * @name  Bastion.sync-plans.controller:SyncPlanAddProductsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires SyncPlan
 * @requires Product
 * @requires CurrentOrganization
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding products to a sync plan.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanAddProductsController',
    ['$scope', '$q', '$location', 'translate', 'SyncPlan', 'Product', 'CurrentOrganization', 'Nutupane',
        function ($scope, $q, $location, translate, SyncPlan, Product, CurrentOrganization, Nutupane) {
            var productsNutupane, params;

            $scope.successMessages = [];
            $scope.errorMessages = [];

            params = {
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'full_result': true,
                'organization_id': CurrentOrganization,
                'sync_plan_id': $scope.$stateParams.syncPlanId,
                'available_for': 'sync_plan'
            };

            productsNutupane = new Nutupane(Product, params);
            $scope.table = productsNutupane.table;

            $scope.addProducts = function () {
                var data,
                    success,
                    error,
                    deferred = $q.defer(),
                    productsToAdd = _.map($scope.table.getSelected(), 'id');

                data = {
                    "product_ids": productsToAdd
                };

                success = function (response) {
                    $scope.successMessages = [translate('Added %x products to sync plan "%y".')
                        .replace('%x', $scope.table.numSelected).replace('%y', $scope.syncPlan.name)];
                    $scope.table.working = false;
                    $scope.table.selectAll(false);
                    productsNutupane.refresh();
                    $scope.syncPlan.$get();
                    deferred.resolve(response);
                };

                error = function (response) {
                    deferred.reject(response.data.errors);
                    $scope.errorMessages = response.data.errors.base;
                    $scope.table.working = false;
                };

                $scope.table.working = true;
                SyncPlan.addProducts({id: $scope.syncPlan.id}, data, success, error);
                return deferred.promise;
            };
        }]
);
