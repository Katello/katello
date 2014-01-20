/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Bastion.systems.controller:SystemsController
 *
 * @requires $scope
 * @requires $location
 * @requires gettext
 * @requires Nutupane
 * @requires System
 * @requires CurrentOrganization
 * @requires SystemsHelper
 *
 * @description
 *   Provides the functionality specific to Systems for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.systems').controller('SystemsController',
    ['$scope', '$location', 'gettext', 'Nutupane', 'System', 'CurrentOrganization', 'SystemsHelper',
    function ($scope, $location, gettext, Nutupane, System, CurrentOrganization, SystemsHelper) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC'
        };

        var nutupane = new Nutupane(System, params);
        $scope.systemTable = nutupane.table;
        $scope.removeRow = nutupane.removeRow;
        $scope.nutupane = nutupane;

        nutupane.enableSelectAllResults();

        if ($location.search()['select_all']) {
            nutupane.table.selectAllResults(true);
        }

        $scope.systemTable.getStatusColor = SystemsHelper.getStatusColor;

        $scope.systemTable.closeItem = function () {
            $scope.transitionTo('systems.index');
        };

        $scope.table = $scope.systemTable;

        $scope.removeSystem = function (system) {
            system.$remove(function () {
                $scope.removeRow(system.id);
                $scope.successMessages.push(gettext('System %s has been deleted.').replace('%s', system.name));
                $scope.transitionTo('systems.index');
            });
        };
    }]
);
