/**
 * Copyright 2015 Red Hat, Inc.
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
 * @name  Bastion.docker-tags.controller:DockerTagsController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires DockerTag
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to docker tags for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.docker-tags').controller('DockerTagsController',
    ['$scope', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization',
    function ($scope, $location, Nutupane, DockerTag, CurrentOrganization) {

        var params = {
            'organization_id':  CurrentOrganization,
            'sort_by':          'name',
            'sort_order':       'ASC',
            'grouped':          true
        };

        var nutupane = new Nutupane(DockerTag, params);
        $scope.table = nutupane.table;

        $scope.table.closeItem = function () {
            $scope.transitionTo('docker-tags.index');
        };
    }]
);
