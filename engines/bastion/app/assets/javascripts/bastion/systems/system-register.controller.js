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
 * @name  Bastion.systems.controller:RegisterSystemController
 *
 * @requires $scope
 * @requires $location
 * @requires Node
 * @requires CurrentOrganization
 * @requires BastionConfig
 *
 * @description
 *     Provides values to populate the code commands for registering a system.
 */
angular.module('Bastion.systems').controller('SystemRegisterController',
    ['$scope', '$location', 'Node', 'CurrentOrganization', 'BastionConfig',
    function ($scope, $location, Node, CurrentOrganization, BastionConfig) {

        $scope.organization = CurrentOrganization;
        $scope.baseURL = 'http://' + $location.host();
        $scope.consumerCertRPM = BastionConfig.consumerCertRPM;

        $scope.nodes = Node.query(function (data) {
            $scope.selectedNode = data.results[0];
        });

    }]
);
