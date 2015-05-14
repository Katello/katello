/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:PackageGroupFilterController
 *
 * @requires $scope
 *
 * @description
 *   Provides common functionality on the $scope for PackageGroup filters.
 */
angular.module('Bastion.content-views').controller('PackageGroupFilterController',
    ['$scope', function ($scope) {

        $scope.successMessages = [];
        $scope.errorMessages = [];
    }]
);
