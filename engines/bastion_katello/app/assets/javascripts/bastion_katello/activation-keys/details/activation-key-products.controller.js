/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyProductsController
 *
 * @requires $scope
 * @requires translate
 * @requires ActivationKey
 * @requires Product
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the activation-key products action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyProductsController',
    ['$scope', 'translate', 'ActivationKey', 'Product', 'CurrentOrganization',
    function ($scope, translate, ActivationKey, Product, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.displayArea = { working: true, isAvailableContent: false };

        $scope.isAnyAvailableContent = function (products) {
            var isAvailableContent = false;
            angular.forEach(products, function (product) {
                if (product['available_content'].length > 0) {
                    isAvailableContent = true;
                }
            });
            return isAvailableContent;
        };

        $scope.productType = "redhat";
        $scope.allProducts = false;

        $scope.refreshProducts = function () {
            var params;

            if ($scope.activationKey.$resolved === false) {
                return;
            }

            $scope.displayArea.working = true;

            params = {
                id: $scope.activationKey.id,
                'organization_id': CurrentOrganization,
                enabled: true,
                'full_result': true,
                'include_available_content': true
            }

            var custom;
            if ($scope.productType === "custom") {
                params['custom'] = true;
            }
            if ($scope.allProducts == true) {
                params['available_for'] = "organization";
            }
            ActivationKey.products(params, function (response) {
                $scope.products = response.results;
                $scope.displayArea.isAvailableContent = $scope.isAnyAvailableContent($scope.products);
                $scope.displayArea.working = false;
            });
        };

        $scope.activationKey.$promise.then($scope.refreshProducts());
        $scope.$watch('productType', $scope.refreshProducts());
    }]
);
