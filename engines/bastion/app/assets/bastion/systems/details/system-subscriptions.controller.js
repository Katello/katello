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
 * @name  Bastion.subscriptions.controller:SystemSubscriptionsController
 *
 * @requires $scope
 * @requires System
 * @requires Subscriptions
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemSubscriptionsController', ['$scope', 'System', 'Subscriptions',
    function($scope, System, Subscriptions) {
        $scope.systemSubscriptions = System.subscriptions({id: $scope.$stateParams.systemId});
        $scope.availableSubscriptions = Subscriptions.query();
    }
]);
