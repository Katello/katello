/**
 * Copyright 2013 Red Hat, Inc.
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
 * @requires $state
 * @requires Nutupane
 * @requires Routes
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductsController',
    ['$scope', '$state', 'Nutupane', 'Product', 'CurrentOrganization', '$location',
    function($scope, $state, Nutupane, Product, CurrentOrganization, $location) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'offset':           0,
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        var nutupane = new Nutupane(Product, params);
        $scope.table = nutupane.table;

        $scope.table.openDetails = function (product) {
            $state.transitionTo('products.details.info', {productId: product.id});
        };

        $scope.transitionTo = function(state) {
            $state.transitionTo(state);
        };

        $scope.table.closeItem = function() {
            $state.transitionTo('products.index');
        };

    }]
);
