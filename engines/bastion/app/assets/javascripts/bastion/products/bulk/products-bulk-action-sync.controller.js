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
 * @name  Bastion.products.controller:ProductsBulkActionSyncController
 *
 * @requires $scope
 * @requires translate
 * @requires ProductBulkAction
 *
 * @description
 *   A controller for providing bulk sync functionality for products..
 */
angular.module('Bastion.products').controller('ProductsBulkActionSyncController',
    ['$scope', 'translate', 'ProductBulkAction', function ($scope, translate, ProductBulkAction) {
        $scope.repositoryCount = 0;
        $scope.syncingProducts = false;

        $scope.syncProducts = function () {
            var success, error;

            $scope.syncingProducts = true;
            $scope.actionParams.ids = $scope.getSelectedProductIds();

            success = function (data) {
                $scope.$parent.successMessages = data.displayMessages.success;
                $scope.$parent.errorMessages = data.displayMessages.error;
                $scope.syncingProducts = false;
            };

            error = function (error) {
                angular.forEach(error.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred syncing the Products: ") + errorMessage);
                });
                $scope.syncingProducts = false;
            };

            ProductBulkAction.syncProducts($scope.actionParams, success, error);

        };
    }]
);
