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
angular.module('Bastion.systems').controller('SystemDetailsController', ['$scope', '$state', 'System',
    function($scope, $state, System) {

        $scope.system = System.get({systemId: $scope.$stateParams.systemId});

        $scope.table.closeItem = function() {
            $state.transitionTo('systems.index');
            $scope.table.showColumns();
        };

        $scope.$watch('table.total', function(total) {
            if (total > 0) {
                $scope.table.reduceColumns(0);
            }
        });
    }
]);
