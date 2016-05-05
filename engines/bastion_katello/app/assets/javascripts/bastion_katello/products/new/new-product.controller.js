/**
 * @ngdoc object
 * @name  Bastion.products.controller:NewProductController
 *
 * @requires $scope
 * @requires Product
 *
 * @description
 *   Controls the creation of an empty Product object for use by sub-controllers.
 */
angular.module('Bastion.products').controller('NewProductController',
    ['$scope', 'Product', 'CurrentOrganization',
    function ($scope, Product, CurrentOrganization) {
        $scope.product = new Product({'organization_id': CurrentOrganization});
        $scope.page = {loading: true};
    }]
);
