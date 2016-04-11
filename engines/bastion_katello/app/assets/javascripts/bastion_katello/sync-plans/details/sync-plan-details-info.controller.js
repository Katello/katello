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

            function updateSyncPlan(syncPlan) {
                syncPlan.syncDate = syncPlan.syncTime = syncPlan['sync_date'];
                $scope.syncPlan = syncPlan;
            }

            SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function (syncPlan) {
                $scope.panel.loading = false;

                updateSyncPlan(syncPlan);
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
                    updateSyncPlan(syncPlan);
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
