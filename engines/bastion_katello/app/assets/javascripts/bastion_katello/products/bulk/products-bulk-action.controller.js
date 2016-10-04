/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkActionController
 *
 * @requires $scope
 * @requires translate
 * @requires ProductBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkActionController',
    ['$scope', 'translate', 'ProductBulkAction', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, translate, ProductBulkAction, CurrentOrganization, GlobalNotification) {

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
            return _.map(rows, 'id');
        };

        $scope.removeProducts = function () {
            var success, error;

            $scope.removingProducts = true;
            $scope.actionParams.ids = $scope.getSelectedProductIds();

            success = function (data) {
                $scope.productsNutupane.refresh();
                $scope.table.selectAll(false);

                angular.forEach(data.displayMessages.success, function(message) {
                    GlobalNotification.setSuccessMessage(message);
                });

                angular.forEach(data.displayMessages.error, function(message) {
                    GlobalNotification.setErrorMessage(message);
                });

                $scope.removingProducts = false;
                $scope.transitionTo('products.index');
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    GlobalNotification.setErrorMessage(translate("An error occurred removing the Products: ") + errorMessage);
                });
                $scope.removingProducts = false;
            };

            ProductBulkAction.removeProducts($scope.actionParams, success, error);
        };
    }]
);
