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
