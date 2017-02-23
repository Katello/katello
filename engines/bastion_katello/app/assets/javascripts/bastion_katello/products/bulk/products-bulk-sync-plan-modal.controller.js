/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkSyncPlanModalController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires Nutupane
 * @requires ProductBulkAction
 * @requires SyncPlan
 * @requires CurrentOrganization
 * @requires GlobalNotification
 * @requires $uibModalInstance
 * @requires bulkParams
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkSyncPlanModalController',
    ['$scope', '$state', 'translate', 'Nutupane', 'ProductBulkAction', 'SyncPlan', 'CurrentOrganization', 'GlobalNotification', '$uibModalInstance', 'bulkParams',
        function ($scope, $state, translate, Nutupane, ProductBulkAction, SyncPlan, CurrentOrganization, GlobalNotification, $uibModalInstance, bulkParams) {
            var success, error, nutupane, params;

            params = {
                'organization_id': CurrentOrganization,
                'offset': 0,
                'sort_by': 'name',
                'sort_order': 'ASC',
                'paged': true
            };

            nutupane = new Nutupane(SyncPlan, params, 'queryPaged');
            $scope.controllerName = 'katello_sync_plans';
            nutupane.masterOnly = true;

            $scope.table = nutupane.table;

            success = function (response) {
                angular.forEach(response.displayMessages.success, function(message) {
                    GlobalNotification.setSuccessMessage(message);
                });

                angular.forEach(response.displayMessages.error, function(message) {
                    GlobalNotification.setErrorMessage(message);
                });

                nutupane.invalidate();
            };

            error = function (response) {
                angular.forEach(response.data.errors, function(message) {
                    GlobalNotification.setErrorMessage(translate("An error occurred updating the sync plan: " ) + message);
                });
            };

            $scope.selectSyncPlan = function (syncPlan) {
                $scope.selectedSyncPlan = syncPlan;
            };

            $scope.updateSyncPlan = function () {
                var updateParams = bulkParams;
                updateParams['plan_id'] = $scope.selectedSyncPlan.id;
                ProductBulkAction.updateProductSyncPlan(updateParams, success, error);
            };

            $scope.removeSyncPlan = function () {
                var removeParams = bulkParams;
                removeParams['plan_id'] = null;
                ProductBulkAction.updateProductSyncPlan(removeParams, success, error);
            };

            $scope.ok = function () {
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
