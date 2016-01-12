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
    ['$scope', 'Nutupane', 'SyncPlan', 'ProductBulkAction', 'GlobalNotification',
    function ($scope, Nutupane, SyncPlan, ProductBulkAction, GlobalNotification) {
        var syncPlanNutupane = new Nutupane(SyncPlan);

        $scope.syncPlanTable = syncPlanNutupane.table;
        syncPlanNutupane.query();

        function success(response) {
            angular.forEach(response.displayMessages.success, function(message) {
                GlobalNotification.setSuccessMessage(message);
            });

            angular.forEach(response.displayMessages.error, function(message) {
                GlobalNotification.setErrorMessage(message);
            });
            $scope.updatingSyncPlans = false;
        }

        function error(response) {
            angular.forEach(response.data.errors, function(message) {
                GlobalNotification.setErrorMessage("An error occurred updating the sync plan: " + message);
            });
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
