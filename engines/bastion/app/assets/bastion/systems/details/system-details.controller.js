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
 * @name  Bastion.systems.controller:SystemDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires System
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemDetailsController', ['$scope', '$state', 'System', function($scope, $state, System) {
    $scope.system = System.get({id: $scope.$stateParams.systemId}, function(system) {
        $scope.$watch("table.rows.length > 0", function() {
            $scope.table.replaceRow(system);
        });
    });

    $scope.transitionTo = function(state) {
        if ($scope.system && $scope.system.hasOwnProperty("uuid")) {
            $state.transitionTo(state, {systemId: $scope.system["uuid"]});
        }
    };

    $scope.isState = function (stateName) {
        return $state.is(stateName);
    };
}]);
