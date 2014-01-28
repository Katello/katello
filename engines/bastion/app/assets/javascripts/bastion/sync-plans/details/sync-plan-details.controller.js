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
 * @name  Bastion.sync-plan.controller:SyncPlanDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires SyncPlan
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsController',
    ['$scope', '$state', 'SyncPlan', function ($scope, $state, SyncPlan) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.syncPlan) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.syncPlan = SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function () {
            $scope.panel.loading = false;
        });
    }]
);
