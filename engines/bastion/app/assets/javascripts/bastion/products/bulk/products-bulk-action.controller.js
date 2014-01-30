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
 * @name  Bastion.products.controller:ProductsBulkActionController
 *
 * @requires $scope
 * @requires gettext
 * @requires ProductBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkActionController',
    ['$scope', 'gettext', 'ProductBulkAction', 'CurrentOrganization',
    function ($scope, gettext, ProductBulkAction, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.removeProducts = {
            confirm: false,
            workingMode: false
        };

        $scope.actionParams = {
            ids: [],
            'organization_id': CurrentOrganization
        };

        $scope.getSelectedProductIds = function () {
            var rows = $scope.productTable.getSelected();
            return _.pluck(rows, 'cp_id');
        };

        $scope.removeProducts = function () {
            var success, error;

            $scope.removingProducts = true;
            $scope.actionParams.ids = $scope.getSelectedProductIds();

            success = function (data) {
                angular.forEach($scope.productTable.getSelected(), function (row) {
                    $scope.removeRow(row.id);
                });

                $scope.table.selectAll(false);
                $scope.successMessages = data["displayMessages"];
                $scope.removingProducts = false;
                $scope.transitionTo('products.index');
            };

            error = function (error) {
                angular.forEach(error.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred removing the Products: ") + errorMessage);
                });
                $scope.removingProducts = false;
            };

            ProductBulkAction.removeProducts($scope.actionParams, success, error);
        };
    }]
);
