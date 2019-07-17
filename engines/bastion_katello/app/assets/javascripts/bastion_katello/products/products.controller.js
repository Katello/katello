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
    ['$scope', '$state', '$sce', '$location', '$uibModal', 'translate', 'Nutupane', 'Product', 'ProductBulkAction', 'CurrentOrganization', 'Notification',
    function ($scope, $state, $sce, $location, $uibModal, translate, Nutupane, Product, ProductBulkAction, CurrentOrganization, Notification) {
        var nutupane, nutupaneParams, getBulkParams, bulkError, params;

        getBulkParams = function () {
            return {
                ids: _.map($scope.table.getSelected(), 'id'),
                'organization_id': CurrentOrganization
            };
        };

        bulkError = function (response) {
            angular.forEach(response.data.errors, function(message) {
                Notification.setErrorMessage(translate("An error occurred: ") + message);
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

        nutupaneParams = {
            'disableAutoLoad': true
        };
        $scope.disableRepoDiscovery = true;
        nutupane = new Nutupane(Product, params, undefined, nutupaneParams);
        $scope.controllerName = 'katello_products';
        nutupane.masterOnly = true;
        nutupane.refresh().then(function () {
            $scope.disableRepoDiscovery = false;
        });
        $scope.table = nutupane.table;

        $scope.$on('productDelete', function (event, taskId) {
            var message = translate("Product delete operation has been initiated in the background.");
            Notification.setSuccessMessage(message, {
                link: {
                    children: translate("Click to view task"),
                    href: translate("/foreman_tasks/tasks/%taskId").replace('%taskId', taskId)
                }});
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
                var message = translate("Product sync has been initiated in the background.");
                Notification.setSuccessMessage(message, {
                    link: {
                        children: translate("Click to monitor task progress."),
                        href: translate("/foreman_tasks/tasks/%taskId").replace('%taskId', task.id)
                    }});
            };

            ProductBulkAction.syncProducts(getBulkParams(), success, bulkError);
        };

        $scope.goToDiscoveries = function () {
            nutupane.table.rows = [];
            nutupane.table.resource.results = [];
            nutupane.table.resource.total = 0;
            nutupane.table.resource.subtotal = 0;
            $state.go("product-discovery.scan");
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

        $scope.openHttpProxyModal = function () {
            nutupane.invalidate();
            $uibModal.open({
                templateUrl: 'products/bulk/views/products-bulk-http-proxy-modal.html',
                controller: 'ProductsBulkHttpProxyModalController',
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

        $scope.openAdvancedSyncModal = function () {
            nutupane.invalidate();
            $uibModal.open({
                templateUrl: 'products/bulk/views/products-bulk-advanced-sync-modal.html',
                controller: 'ProductsBulkAdvancedSyncModalController',
                size: 'lg',
                resolve: {
                    bulkParams: function () {
                        return getBulkParams();
                    }
                }
            });
        };

        $scope.removeProducts = function () {
            var success;

            success = function (response) {
                angular.forEach(response.displayMessages.success, function(message) {
                    Notification.setSuccessMessage(message);
                });

                angular.forEach(response.displayMessages.error, function(message) {
                    Notification.setErrorMessage(message);
                });

                nutupane.refresh();
            };

            ProductBulkAction.removeProducts(getBulkParams(), success, bulkError);
        };
    }]
);
