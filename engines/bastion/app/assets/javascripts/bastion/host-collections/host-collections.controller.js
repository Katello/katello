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
 * @name  Bastion.host-collections.controller:HostCollectionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to host collections for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.host-collections').controller('HostCollectionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, HostCollection, CurrentOrganization) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        var nutupane = new Nutupane(HostCollection, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.closeItem = function () {
            $scope.transitionTo('host-collections.index');
        };

        $scope.$on("updateContentHostCollection", function (event, hostCollectionRow) {
            $scope.table.replaceRow(hostCollectionRow);
        });

    }]
);
