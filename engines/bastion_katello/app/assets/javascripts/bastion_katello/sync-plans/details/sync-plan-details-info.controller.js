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
                var syncDate, splitDates;
                if (syncPlan['sync_date']) {
                    // Firefox doesn't work with new Date(2021-10-04 18:57:00 -0400)
                    //Needs to be in format YYYY-MM-DDTHH:mm:ss.sssZ
                    // see: https://262.ecma-international.org/5.1/#sec-15.9.1.15
                    splitDates = syncPlan['sync_date'].split(' ');
                    syncDate = new Date(splitDates[0] + 'T' + splitDates[1] + splitDates[2]);
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

                var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric' };

                syncDate.setHours(syncTime.getHours());
                syncDate.setMinutes(syncTime.getMinutes());
                syncDate.setSeconds(0);
                syncPlan['sync_date'] = syncDate.toLocaleString("en-US", options);
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
