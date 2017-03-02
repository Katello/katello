/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsController
 *
 * @requires $scope
 * @requires $state
 * @requires $sce
 * @requires $location
 * @requires $uibModal
 * @requires translate
 * @requires Nutupane
 * @requires Product
 * @requires ProductBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductsController',
    ['$scope', '$state', '$sce', '$location', '$uibModal', 'translate', 'Nutupane', 'Product', 'ProductBulkAction', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, $state, $sce, $location, $uibModal, translate, Nutupane, Product, ProductBulkAction, CurrentOrganization, GlobalNotification) {
        var nutupane, taskUrl, taskLink, getBulkParams, bulkError, params;

        getBulkParams = function () {
            return {
                ids: _.map($scope.table.getSelected(), 'id'),
                'organization_id': CurrentOrganization
            };
        };

        bulkError = function (response) {
            angular.forEach(response.data.errors, function(message) {
                GlobalNotification.setErrorMessage(translate("An error occurred updating the sync plan: ") + message);
            });

            nutupane.refresh();
        };

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'enabled': true,
            'paged': true
        };

        nutupane = new Nutupane(Product, params);
        $scope.controllerName = 'katello_products';
        $scope.current_organization = CurrentOrganization;
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;

        $scope.$on('productDelete', function (event, taskId) {
            var message;
            taskUrl = $scope.taskUrl(taskId);
            taskLink = $sce.trustAsHtml("<a href=" + taskUrl + ">here</a>");
            message = translate("Product delete operation has been initiated in the background. Click %s to monitor the progress.");
            GlobalNotification.setRenderedSuccessMessage(message.replace("%", taskLink));
        });

        $scope.unsetProductDeletionTaskId = function () {
            $scope.productDeletionTaskId = undefined;
        };

        $scope.mostImportantSyncState = function (product) {
            var state = 'none';
            if (product['sync_summary'].pending > 0) {
                state = 'pending';
            } else if (product['sync_summary'].error > 0) {
                state = 'error';
            } else if (product['sync_summary'].warning > 0) {
                state = 'warning';
            } else if (product['sync_summary'].success > 0) {
                state = 'success';
            }
            return state;
        };

        $scope.syncProducts = function () {
            var success;

            success = function (task) {
                var url = $state.href('task', {taskId: task.id}), message;

                taskLink = $sce.trustAsHtml("<a href=" + url + ">here</a>");
                message = translate("Product sync has been initiated in the background. " +
                    "Click %s to monitor the progress.");

                GlobalNotification.setRenderedSuccessMessage(message.replace('%s', taskLink));
            };

            ProductBulkAction.syncProducts(getBulkParams(), success, bulkError);
        };

        $scope.openSyncPlanModal = function () {
            nutupane.invalidate();
            $uibModal.open({
                templateUrl: 'products/bulk/views/products-bulk-sync-plan-modal.html',
                controller: 'ProductsBulkSyncPlanModalController',
                size: 'lg',
                resolve: {
                    bulkParams: function () {
                        return getBulkParams();
                    }
                }
            }).closed.then(function () {
                nutupane.refresh();
            });
        };

        $scope.removeProducts = function () {
            var success;

            success = function (response) {
                angular.forEach(response.displayMessages.success, function(message) {
                    GlobalNotification.setSuccessMessage(message);
                });

                angular.forEach(response.displayMessages.error, function(message) {
                    GlobalNotification.setErrorMessage(message);
                });

                nutupane.refresh();
            };

            ProductBulkAction.removeProducts(getBulkParams(), success, bulkError);
        };
    }]
);
