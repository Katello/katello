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
    ['$scope', '$state', 'translate', 'ProductBulkAction',
     function ($scope, $state, translate, ProductBulkAction) {
        $scope.repositoryCount = 0;

        $scope.syncProducts = function () {
            $scope.actionParams.ids = $scope.getSelectedProductIds();

            ProductBulkAction.syncProducts($scope.actionParams, function (task) {
                $state.go('task', {taskId: task.id});
            });

        };
    }]
);
