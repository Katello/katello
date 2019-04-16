/**
 * @ngdoc object
 * @name  Bastion.syncPlans.controller:SyncPlanDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires SyncPlan
 * @requires MenuExpander
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsInfoController',
    ['$scope', '$q', 'translate', 'SyncPlan', 'MenuExpander', 'Notification',
        function ($scope, $q, translate, SyncPlan, MenuExpander, Notification) {
            $scope.intervals = [
                {id: 'hourly', value: translate('hourly')},
                {id: 'daily', value: translate('daily')},
                {id: 'weekly', value: translate('weekly')},
                {id: 'custom cron', value: translate('custom cron')}
            ];

            $scope.menuExpander = MenuExpander;
            $scope.panel = $scope.panel || {loading: false};
            $scope.editInterval = false;
            $scope.editedInterval = false;

            function updateSyncPlan(syncPlan) {
                var syncDate;
                if (syncPlan['sync_date']) {
                    syncDate = new Date(syncPlan['sync_date'].replace(/\s/, 'T').replace(/\s/, ''));
                } else {
                    syncDate = new Date();
                }

                syncPlan.syncDate = syncDate;
                syncPlan.syncTime = syncDate;
                $scope.syncPlan = syncPlan;
            }

            SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function (syncPlan) {
                $scope.panel.loading = false;
                $scope.syncPlanInterval = syncPlan.interval;
                updateSyncPlan(syncPlan);

                $scope.$watch('syncPlan.interval', function (interval) {
                    if (interval !== $scope.syncPlanInterval) {
                        $scope.editInterval = true;
                        $scope.editedInterval = false;
                        $scope.workingText = translate('Working');
                        if (interval === "custom cron") {
                            $scope.editedInterval = true;
                            $scope.workingText = translate('Please enter cron below');
                        }
                    } else {
                        $scope.editedInterval = false;
                        $scope.editInterval = false;
                    }
                });
            });
            $scope.cancelCronEdit = function () {
                $scope.$state.reload();
            };
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
                    Notification.setSuccessMessage(translate('Sync Plan Saved'));
                    $scope.editInterval = false;
                    $scope.editedInterval = false;
                }, function (response) {
                    deferred.reject(response);
                    angular.forEach(response.data.errors, function (errorMessage, key) {
                        if (angular.isString(key)) {
                            errorMessage = [key, errorMessage].join(' ');
                        }
                        Notification.setErrorMessage(translate("An error occurred saving the Sync Plan: ") + errorMessage);
                    });
                });
                return deferred.promise;
            };
        }]
);
