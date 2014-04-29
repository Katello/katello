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
 * @name  Bastion.sync-plans.controller:NewSyncPlanController
 *
 * @requires $scope
 * @requires translate
 * @requires SyncPlan
 *
 * @description
 *   Controls the creation of an empty SyncPlan object for use by sub-controllers.
 */
angular.module('Bastion.sync-plans').controller('NewSyncPlanController',
    ['$scope', 'translate', 'SyncPlan', function ($scope, translate, SyncPlan) {
        var now = new Date();
        $scope.intervals = [translate('none'), translate('hourly'), translate('daily'), translate('weekly')];
        $scope.successMessages = [];

        $scope.syncPlan = new SyncPlan();
        $scope.syncPlan.startDate = now;
        $scope.syncPlan.startTime = now;
        $scope.syncPlan.interval = $scope.intervals[0];

        function success(syncPlan) {
            $scope.working = false;
            $scope.successMessages = [translate('New sync plan successfully created.')];
            if ($scope.product) {
                $scope.product['sync_plan_id'] = syncPlan.id;
            } else if ($scope.syncPlanTable) {
                $scope.syncPlanTable.rows.unshift(syncPlan);
            }
            $scope.transitionBack();
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.syncPlanForm[field].$setValidity('server', false);
                $scope.syncPlanForm[field].$error.messages = errors;
            });
        }

        $scope.createSyncPlan = function (syncPlan) {
            syncPlan['sync_date'] = [syncPlan.startDate, syncPlan.startTime].join(' ');
            syncPlan.$save(success, error);
        };
    }]
);
