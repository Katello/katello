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
 * @name  Bastion.sync-plans.controller:NewSyncPlanController
 *
 * @requires $scope
 * @requires gettext
 * @requires SyncPlan
 *
 * @description
 *   Controls the creation of an empty SyncPlan object for use by sub-controllers.
 */
angular.module('Bastion.sync-plans').controller('NewSyncPlanController',
    ['$scope', 'gettext', 'SyncPlan', function ($scope, gettext, SyncPlan) {
        var now = new Date();
        $scope.intervals = [gettext('none'), gettext('hourly'), gettext('daily'), gettext('weekly')];
        $scope.successMessages = [];
        $scope.errorMessages = [];


        $scope.syncPlan = new SyncPlan();
        $scope.syncPlan.startDate = now;
        $scope.syncPlan.startTime = now;
        $scope.syncPlan.interval = $scope.intervals[0];

        function success(response) {
            $scope.working = false;
            $scope.successMessages = response.displayMessages;
            if ($scope.product) {
                $scope.product['sync_plan_id'] = $scope.syncPlan.id;
            } else if ($scope.syncPlanTable) {
                $scope.syncPlanTable.rows.unshift($scope.syncPlan);
            }
            $scope.transitionBack();
        }

        function error(response) {
            $scope.working = false;
            $scope.errorMessages = response.data.errors;
        }

        $scope.createSyncPlan = function (syncPlan) {
            syncPlan['sync_date'] = [syncPlan.startDate, syncPlan.startTime].join(' ');
            syncPlan.$save(success, error);
        };
    }]
);
