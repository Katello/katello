/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataDetailsController
 *
 * @requires $scope
 * @requires Errata
 *
 * @description
 *   Provides the functionality for the errata details action pane.
 */
angular.module('Bastion.packages').controller('PackageDetailsController', ['$scope', 'Package',
    function ($scope, Package) {
        if ($scope.package) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.package = Package.get({id: $scope.$stateParams.packageId}, function () {
            $scope.panel.loading = false;
        });
    }
]);
