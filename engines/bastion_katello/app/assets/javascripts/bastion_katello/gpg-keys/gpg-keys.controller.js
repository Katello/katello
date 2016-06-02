/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:GPGKeysController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires GPGKey
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to GPGKeys for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeysController',
    ['$scope', '$location', 'Nutupane', 'GPGKey', 'CurrentOrganization',
    function ($scope, $location, Nutupane, GPGKey, CurrentOrganization) {
        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        var nutupane = new Nutupane(GPGKey, params);
        $scope.table = nutupane.table;
        $scope.panel = {loading: false};
        $scope.removeRow = nutupane.removeRow;
        $scope.controllerName = 'katello_gpg_keys';

        if ($scope.$state.current.collapsed) {
            $scope.panel.loading = true;
        }

        $scope.table.openGPGKey = function (gpgKey) {
            $scope.panel.loading = true;
            $scope.transitionTo('gpg-keys.details.info', {gpgKeyId: gpgKey.id});
        };

        $scope.transitionToNewGPGKey = function () {
            $scope.panel.loading = true;
            $scope.transitionTo('gpg-keys.new');
        };

        $scope.table.closeItem = function () {
            $scope.transitionTo('gpg-keys.index');
        };

    }]
);
