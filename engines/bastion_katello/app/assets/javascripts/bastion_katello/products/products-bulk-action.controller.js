/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkActionController
 *
 * @requires $scope
 * @requires $state
 * @requires $sce
 * @requires translate
 * @requires ProductBulkAction
 * @requires SyncPlan
 * @requires CurrentOrganization
 * @requires GlobalNotification
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkActionController',
    ['$scope', '$state', '$sce', 'translate', 'ProductBulkAction', 'SyncPlan', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, $state, $sce, translate, ProductBulkAction, SyncPlan, CurrentOrganization, GlobalNotification) {
        var refreshTable, successDisplayMessages, error;

        refreshTable = function () {
            $scope.productsNutupane.refresh();
            $scope.table.selectAll(false);
        };

        successDisplayMessages = function (response) {
            angular.forEach(response.displayMessages.success, function(message) {
                GlobalNotification.setSuccessMessage(message);
            });

            angular.forEach(response.displayMessages.error, function(message) {
                GlobalNotification.setErrorMessage(message);
            });

            refreshTable();
        };

        error = function (response) {
            angular.forEach(response.data.errors, function(message) {
                GlobalNotification.setErrorMessage("An error occurred updating the sync plan: " + message);
            });
        };

        $scope.removeProducts = {
            confirm: false,
            workingMode: false
        };

        $scope.actionParams = {
            ids: [],
            'organization_id': CurrentOrganization
        };

        $scope.syncPlans = SyncPlan.queryUnpaged();

        $scope.getSelectedProductIds = function () {
            var rows = $scope.table.getSelected();
            return _.map(rows, 'id');
        };

        $scope.syncProducts = function () {
            var success = function (task) {
                var url = $state.href('task', {taskId: task.id}),
                    taskLink = $sce.trustAsHtml("<a href=" + url + ">here</a>"),
                    message = "Product sync has been initiated in the background. " +
                        "Click " + taskLink + " to monitor the progress.";

                GlobalNotification.setRenderedSuccessMessage(translate(message));
            };

            $scope.actionParams.ids = $scope.getSelectedProductIds();
            ProductBulkAction.syncProducts($scope.actionParams, success, error);
        };

        $scope.removeProducts = function () {
            $scope.actionParams.ids = $scope.getSelectedProductIds();
            ProductBulkAction.removeProducts($scope.actionParams, successDisplayMessages, error);
        };

        $scope.updateSyncPlan = function (syncPlan) {
            $scope.actionParams.ids = $scope.getSelectedProductIds();
            $scope.actionParams['plan_id'] = syncPlan.id;
            ProductBulkAction.updateProductSyncPlan($scope.actionParams, successDisplayMessages, error);
        };

        $scope.removeSyncPlan = function () {
            $scope.actionParams.ids = $scope.getSelectedProductIds();
            $scope.actionParams['plan_id'] = null;
            ProductBulkAction.updateProductSyncPlan($scope.actionParams, successDisplayMessages, error);
        };
    }]
);
