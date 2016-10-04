/**
 * @ngdoc object
 * @name  Bastion.sync-plans.controller:SyncPlanProductsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires SyncPlan
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the sync plan list products details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanProductsController',
    ['$scope', '$q', '$location', 'translate', 'SyncPlan', 'Nutupane',
        function ($scope, $q, $location, translate, SyncPlan, Nutupane) {
            var productsNutupane, params;

            $scope.successMessages = [];
            $scope.errorMessages = [];

            params = {
                'id': $scope.$stateParams.syncPlanId,
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'full_result': true
            };

            productsNutupane = new Nutupane(SyncPlan, params, 'products');
            $scope.productsTable = productsNutupane.table;

            $scope.removeProducts = function () {
                var data,
                    success,
                    error,
                    deferred = $q.defer(),
                    productsToRemove = _.map($scope.productsTable.getSelected(), 'id');

                data = {
                    "product_ids": productsToRemove
                };

                success = function (response) {
                    $scope.successMessages = [translate('Removed %x products from sync plan "%y".')
                        .replace('%x', $scope.productsTable.numSelected).replace('%y', $scope.syncPlan.name)];
                    $scope.productsTable.working = false;
                    $scope.productsTable.selectAll(false);
                    productsNutupane.refresh();
                    $scope.syncPlan.$get();
                    deferred.resolve(response);
                };

                error = function (response) {
                    deferred.reject(response.data.errors);
                    $scope.errorMessages = response.data.errors;
                    $scope.productsTable.working = false;
                };

                $scope.productsTable.working = true;
                SyncPlan.removeProducts({id: $scope.syncPlan.id}, data, success, error);
                return deferred.promise;
            };
        }]
);
