/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsInstalledController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostDeb
 * @requires translate
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host deb packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsInstalledController',
    ['$scope', '$timeout', '$window', 'HostDeb', 'translate', 'Nutupane',
    function ($scope, $timeout, $window, HostDeb, translate, Nutupane) {
        var debsNutupane;

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Installed Deb Packages');

        $scope.removeSelectedDebs = function () {
            var selected;

            if (!$scope.working) {
                $scope.working = true;
                selected = $scope.table.getSelected().map(function (p) {
                    return p.name;
                }).join(' ');
                $scope.performPackageAction('packageRemove', selected);
            }
        };

        debsNutupane = new Nutupane(HostDeb, {id: $scope.$stateParams.hostId});
        debsNutupane.primaryOnly = true;
        $scope.table = debsNutupane.table;
        $scope.table.contentHost = $scope.contentHost;
    }
]);
