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
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'enabled' :         true,
            'paged':            true
        };

        $scope.productsNutupane = new Nutupane(Product, params);
        $scope.productTable = $scope.productsNutupane.table;
        $scope.removeRow = $scope.productsNutupane.removeRow;

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
            if (product['sync_summary']['pending'] > 0) {
                state = 'pending';
            } else if (product['sync_summary']['error'] > 0) {
                state = 'error';
            } else {
                state = 'success';
            }
            return state;
        };

    }]
);
