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
 * @name  Bastion.content-hosts.controller:ContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ContentHost
 * @requires CurrentOrganization
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality specific to Content Hosts for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'ContentHost', 'CurrentOrganization', 'ContentHostsHelper',
    function ($scope, $location, translate, Nutupane, ContentHost, CurrentOrganization, ContentHostsHelper) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC'
        };

        var nutupane = new Nutupane(ContentHost, params);
        $scope.contentHostTable = nutupane.table;
        $scope.removeRow = nutupane.removeRow;
        $scope.nutupane = nutupane;

        nutupane.enableSelectAllResults();

        if ($location.search()['select_all']) {
            nutupane.table.initialSelectAll = true;
        }

        $scope.contentHostTable.getStatusColor = ContentHostsHelper.getStatusColor;
        $scope.contentHostTable.getProvisioningStatusColor = ContentHostsHelper.getProvisioningStatusColor;

        $scope.contentHostTable.closeItem = function () {
            $scope.transitionTo('content-hosts.index');
        };

        $scope.table = $scope.contentHostTable;

        $scope.unregisterContentHost = function (contentHost) {
            contentHost.$remove(function () {
                $scope.removeRow(contentHost.id);
                $scope.successMessages.push(translate('Content Host %s has been deleted.').replace('%s', contentHost.name));
                $scope.transitionTo('content-hosts.index');
            });
        };
    }]
);
