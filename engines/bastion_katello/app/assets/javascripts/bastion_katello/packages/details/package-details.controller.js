/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataDetailsController
 *
 * @requires $scope
 * @requires Errata
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the errata details action pane.
 */
angular.module('Bastion.packages').controller('PackageDetailsController', ['$scope', 'Package', 'ApiErrorHandler',
    function ($scope, Package, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.package) {
            $scope.panel.loading = false;
        }

        $scope.package = Package.get({id: $scope.$stateParams.packageId}, function () {
            $scope.panel.loading = false;
        }, function(response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }
]);
