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
 * @name  Bastion.systems.controller:SystemSystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires gettext
 * @requires SyncPlan
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the sync plan list products details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanProductsController',
    ['$scope', '$q', '$location', 'gettext', 'SyncPlan', 'Nutupane',
        function ($scope, $q, $location, gettext, SyncPlan, Nutupane) {
            var productsNutupane, params;

            $scope.successMessages = [];
            $scope.errorMessages = [];

            params = {
                'id':          $scope.$stateParams.syncPlanId,
                'search':      $location.search().search || "",
                'sort_by':     'name',
                'sort_order':  'ASC',
                'paged':       true
            };

            productsNutupane = new Nutupane(SyncPlan, params, 'products');
            $scope.productsTable = productsNutupane.table;

            $scope.removeProducts = function () {
                var data,
                    success,
                    error,
                    deferred = $q.defer(),
                    productsToRemove = _.pluck($scope.productsTable.getSelected(), 'id');

                data = {
                    "product_ids": productsToRemove
                };

                success = function (data) {
                    $scope.successMessages = [gettext('Removed %x products from system "%y".')
                        .replace('%x', $scope.productsTable.numSelected).replace('%y', $scope.syncPlan.name)];
                    $scope.productsTable.working = false;
                    $scope.productsTable.selectAll(false);
                    productsNutupane.refresh();
                    $scope.syncPlan.$get();
                    deferred.resolve(data);
                };

                error = function (error) {
                    deferred.reject(error.data.errors);
                    $scope.errorMessages = error.data.errors;
                    $scope.productsTable.working = false;
                };

                $scope.productsTable.working = true;
                SyncPlan.removeProducts({id: $scope.syncPlan.id}, data, success, error);
                return deferred.promise;
            };
        }]
);
