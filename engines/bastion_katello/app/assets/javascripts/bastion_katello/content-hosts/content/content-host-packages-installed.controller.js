/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesInstalledController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostPackage
 * @requires translate
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesInstalledController',
    ['$scope', '$timeout', '$window', 'HostPackage', 'translate', 'Nutupane',
    function ($scope, $timeout, $window, HostPackage, translate, Nutupane) {
        var packagesNutupane;

        $scope.removeSelectedPackages = function () {
            var selected = _.map($scope.table.getSelected(), 'name');

            if (!$scope.working) {
                $scope.working = true;
                $scope.performPackageAction("packageRemove", selected.join(","));
            }
        };

        packagesNutupane = new Nutupane(HostPackage, {id: $scope.$stateParams.hostId});
        packagesNutupane.primaryOnly = true;
        $scope.table = packagesNutupane.table;
        $scope.table.contentHost = $scope.contentHost;
    }
]);
