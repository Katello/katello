/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsController
 *
 * @requires $scope
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
    ['$scope', '$location', 'Nutupane', 'Product', 'CurrentOrganization',
    function ($scope, $location, Nutupane, Product, CurrentOrganization) {

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'enabled': true,
            'paged': true
        };

        $scope.productsNutupane = new Nutupane(Product, params);
        $scope.productTable = $scope.productsNutupane.table;
        $scope.removeRow = $scope.productsNutupane.removeRow;
        $scope.controllerName = 'katello_products';

        $scope.productTable.closeItem = function () {
            $scope.transitionTo('products.index');
        };

        $scope.$on('productDelete', function (event, taskId) {
            $scope.productDeletionTaskId = taskId;
        });

        $scope.unsetProductDeletionTaskId = function () {
            $scope.productDeletionTaskId = undefined;
        };

        $scope.productTable.refresh = $scope.productsNutupane.refresh;

        $scope.table = $scope.productTable;

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
