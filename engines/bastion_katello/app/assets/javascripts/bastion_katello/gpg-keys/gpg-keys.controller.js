/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

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
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        var nutupane = new Nutupane(GPGKey, params);
        $scope.table = nutupane.table;
        $scope.panel = {loading: false};
        $scope.removeRow = nutupane.removeRow;

        if ($scope.$state.current.collapsed) {
            $scope.panel.loading = true;
        }

        $scope.table.openGPGKey = function (gpgKey) {
            $scope.panel.loading = true;
            $scope.transitionTo('gpgKeys.details.info', {gpgKeyId: gpgKey.id});
        };

        $scope.transitionToNewGPGKey = function () {
            $scope.panel.loading = true;
            $scope.transitionTo('gpgKeys.new');
        };

        $scope.table.closeItem = function () {
            $scope.transitionTo('gpgKeys.index');
        };

    }]
);
