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
            $scope.$parent.successMessages = response.displayMessages.success;
            $scope.$parent.errorMessages = response.displayMessages.error;
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
