/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsController
 *
 * @requires $scope
 * @requires $state
 * @requires $sce
 * @requires $location
 * @requires Nutupane
 * @requires Product
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductsController',
    ['$scope', '$state', '$sce', '$location', 'Nutupane', 'Product', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, $state, $sce, $location, Nutupane, Product, CurrentOrganization, GlobalNotification) {
        var taskUrl, taskLink;

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'enabled': true,
            'paged': true
        };

        $scope.productsNutupane = new Nutupane(Product, params);
        $scope.productsNutupane.masterOnly = true;

        $scope.table = $scope.productsNutupane.table;
        $scope.controllerName = 'katello_products';

        $scope.$on('productDelete', function (event, taskId) {
            taskUrl = $scope.taskUrl(taskId);
            taskLink = $sce.trustAsHtml("<a href=" + taskUrl + ">here</a>");
            GlobalNotification.setRenderedSuccessMessage("Product delete operation has been initiated in the background. Click " + taskLink + " click to monitor the progress.");
        });

        $scope.unsetProductDeletionTaskId = function () {
            $scope.productDeletionTaskId = undefined;
        };

        $scope.table.refresh = $scope.productsNutupane.refresh;

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
    }]
);
