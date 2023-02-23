/**
 * @ngdoc object
 * @name  Bastion.packages.controller:PackageController
 *
 * @requires $scope
 * @requires Package
 * @requires Host
 * @requires CurrentOrganization
 * @requires ApiErrorHandler
 * @requires newHostDetailsUI
 *
 * @description
 *   Provides the functionality for the package page.
 */
angular.module('Bastion.packages').controller('PackageController',
    ['$scope', 'Package', 'Host', 'CurrentOrganization', 'ApiErrorHandler', 'newHostDetailsUI', 'newHostDetailsUI',
    function ($scope, Package, Host, CurrentOrganization, ApiErrorHandler, newHostDetailsUI) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.package) {
            $scope.panel.loading = false;
        }

        $scope.installedPackageCount = undefined;
        $scope.newHostDetailsUI = (newHostDetailsUI === 'true');

        $scope.fetchHostCount = function() {
            Host.get({'per_page': 0, 'search': $scope.createSearchString('installed_package'), 'organization_id': CurrentOrganization}, function (data) {
                $scope.installedPackageCount = data.subtotal;
            });
        };

        $scope.createSearchString = function(field) {
            return field + '=' + $scope.package.name + '-' + $scope.package.version + '-' + $scope.package.release + '.' +
                            $scope.package.arch;
        };

        $scope.encodedUrl = function(field) {
            return '/content_hosts?search=' + encodeURIComponent($scope.createSearchString(field));
        };

        $scope.newHostUrl = function(field) {
            return '/hosts?search=' + encodeURIComponent($scope.createSearchString(field));
        };

        $scope.package = Package.get({id: $scope.$stateParams.packageId}, function () {
            $scope.panel.loading = false;
            $scope.fetchHostCount();
        }, function(response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }
]);
