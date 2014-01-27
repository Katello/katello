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
 * @name  Bastion.products.controller:ProductsBulkActionSyncPlanController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires SyncPlan
 * @requires ProductBulkAction
 *
 * @description
 *   A controller for providing bulk sync plan functionality for products.
 */
angular.module('Bastion.products').controller('ProductsBulkActionSyncPlanController',
    ['$scope', 'Nutupane', 'SyncPlan', 'ProductBulkAction',
    function ($scope, Nutupane, SyncPlan, ProductBulkAction) {
        var syncPlanNutupane = new Nutupane(SyncPlan);

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.syncPlanTable = syncPlanNutupane.table;
        syncPlanNutupane.query();

        function success(response) {
            $scope.$parent.successMessages = response.displayMessages;
            $scope.updatingSyncPlans = false;
        }

        function error(response) {
            $scope.$parent.errorMessages = response.data.errors;
            $scope.updatingSyncPlans = false;
        }

        $scope.updateSyncPlan = function () {
            $scope.updatingSyncPlans = true;
            $scope.actionParams.ids = $scope.getSelectedProductIds();
            $scope.actionParams['plan_id'] = $scope.syncPlanTable.chosenRow.id;
            ProductBulkAction.updateProductSyncPlan($scope.actionParams, success, error);
        };

        $scope.removeSyncPlan = function () {
            $scope.updatingSyncPlans = true;
            $scope.actionParams.ids = $scope.getSelectedProductIds();
            $scope.actionParams['plan_id'] = null;
            ProductBulkAction.updateProductSyncPlan($scope.actionParams, success, error);
        };
    }]
);
