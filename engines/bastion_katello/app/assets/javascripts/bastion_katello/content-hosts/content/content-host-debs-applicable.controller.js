/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsApplicableController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires Deb
 * @requires HostDeb
 * @requires translate
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host debs list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsApplicableController',
    ['$scope', '$timeout', '$window', 'Deb', 'HostDeb', 'translate', 'Nutupane',
    function ($scope, $timeout, $window, Deb, HostDeb, translate, Nutupane) {
        var debsNutupane, openEventInfo;

        $scope.getSelectedDebs = function () {
            var selected = $scope.table.getSelected();
            selected = _.map(selected, function(pkg) {
                return pkg.name + ':' + pkg.architecture + '=' + pkg.version;
            });
            return selected;
        };

        $scope.getRemoteExecutionCommand = function() {
            return $scope.getSelectedDebs().join(' ');
        };

        $scope.performRexUpdate = function () {
            $scope.performViaRemoteExecution('packageUpdate', $scope.getRemoteExecutionCommand(), false);
        };

        debsNutupane = new Nutupane(Deb, {'host_id': $scope.$stateParams.hostId, 'packages_restrict_upgradable': true});
        $scope.controllerName = 'katello_erratum_debs';
        debsNutupane.masterOnly = true;
        $scope.table = debsNutupane.table;
        $scope.table.openEventInfo = openEventInfo;
        $scope.table.contentHost = $scope.contentHost;
    }
]);
