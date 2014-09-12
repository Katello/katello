/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

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

                success = function (data) {
                    $scope.successMessages = [translate('Added %x products to sync plan "%y".')
                        .replace('%x', $scope.productsTable.numSelected).replace('%y', $scope.syncPlan.name)];
                    $scope.productsTable.working = false;
                    $scope.productsTable.selectAll(false);
                    productsNutupane.refresh();
                    $scope.syncPlan.$get();
                    deferred.resolve(data);
                };

                error = function (error) {
                    deferred.reject(error.data.errors);
                    $scope.errorMessages = error.data.errors['base'];
                    $scope.productsTable.working = false;
                };

                $scope.productsTable.working = true;
                SyncPlan.addProducts({id: $scope.syncPlan.id}, data, success, error);
                return deferred.promise;
            };
        }]
);
