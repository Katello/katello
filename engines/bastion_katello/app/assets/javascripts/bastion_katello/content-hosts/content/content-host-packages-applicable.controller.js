/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesApplicableController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires Package
 * @requires HostPackage
 * @requires translate
 * @requires Nutupane
 * @requires BastionConfig
 *
 * @description
 *   Provides the functionality for the content host packages list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesApplicableController',
    ['$scope', '$timeout', '$window', 'Package', 'HostPackage', 'translate', 'Nutupane', 'BastionConfig',
    function ($scope, $timeout, $window, Package, HostPackage, translate, Nutupane, BastionConfig) {
        var packagesNutupane, openEventInfo;

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Applicable Packages');

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.hostToolingEnabled = BastionConfig.hostToolingEnabled;

        $scope.getSelectedPackages = function () {
            var selected = $scope.table.getSelected();
            selected = _.map(selected, function(pkg) {
                return pkg.name + '-' + pkg.version + '-' + pkg.release + '.' + pkg.arch;
            });
            return selected;
        };

        $scope.getRemoteExecutionCommand = function() {
            return $scope.getSelectedPackages().join(' ');
        };

        $scope.performRexUpdate = function () {
            $scope.performViaRemoteExecution('packageUpdate', $scope.getRemoteExecutionCommand(), false);
        };

        packagesNutupane = new Nutupane(Package, {'host_id': $scope.$stateParams.hostId, 'packages_restrict_upgradable': true});
        $scope.controllerName = 'katello_erratum_packages';
        packagesNutupane.primaryOnly = true;
        $scope.table = packagesNutupane.table;
        $scope.table.openEventInfo = openEventInfo;
        $scope.table.contentHost = $scope.contentHost;
    }
]);
