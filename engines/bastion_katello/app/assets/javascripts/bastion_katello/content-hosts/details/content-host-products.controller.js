/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostProductsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHost
 * @requires Product
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostProductsController',
    ['$scope', 'translate', 'ContentHost', 'Product', 'CurrentOrganization',
    function ($scope, translate, ContentHost, Product, CurrentOrganization) {

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

        $scope.contentHost.$promise.then(function () {
            ContentHost.products({id: $scope.contentHost.uuid,
                                  'organization_id': CurrentOrganization,
                                  enabled: true,
                                  'full_result': true,
                                  'include_available_content': true
                                 }, function (response) {
                $scope.products = response.results;
                $scope.displayArea.isAvailableContent = $scope.isAnyAvailableContent($scope.products);
                $scope.displayArea.working = false;
            });
        });

    }]
);
