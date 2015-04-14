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
 * @name  Bastion.syncPlans.controller:SyncPlanDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires SyncPlan
 * @requires MenuExpander
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsInfoController',
    ['$scope', '$q', 'translate', 'SyncPlan', 'MenuExpander',
        function ($scope, $q, translate, SyncPlan, MenuExpander) {
            $scope.successMessages = [];
            $scope.errorMessages = [];
            $scope.intervals = [
                {id: 'hourly', value: translate('hourly')},
                {id: 'daily', value: translate('daily')},
                {id: 'weekly', value: translate('weekly')}
            ];

            $scope.menuExpander = MenuExpander;
            $scope.panel = $scope.panel || {loading: false};

            SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function (syncPlan) {
                $scope.panel.loading = false;

                syncPlan.syncDate = syncPlan.syncTime = syncPlan['sync_date'];
                $scope.syncPlan = syncPlan;
            });

            $scope.save = function (syncPlan) {
                var deferred = $q.defer(),
                    syncDate = new Date(syncPlan.syncDate),
                    syncTime = new Date(syncPlan.syncTime || new Date());

                syncDate.setHours(syncTime.getHours());
                syncDate.setMinutes(syncTime.getMinutes());
                syncDate.setSeconds(0);
                syncPlan['sync_date'] = syncDate.toString();

                syncPlan.$update(function (response) {
                    deferred.resolve(response);
                    $scope.successMessages.push(translate('Sync Plan Saved'));
                }, function (response) {
                    deferred.reject(response);
                    angular.forEach(response.data.errors, function (errorMessage, key) {
                        if (angular.isString(key)) {
                            errorMessage = [key, errorMessage].join(' ');
                        }
                        $scope.errorMessages.push(translate("An error occurred saving the Sync Plan: ") + errorMessage);
                    });
                });
                
                return deferred.promise;
            };
        }]
);
