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
    ['$scope', 'translate', 'SyncPlan', 'GlobalNotification',
        function ($scope, translate, SyncPlan, GlobalNotification) {
            $scope.intervals = [
                {id: 'hourly', value: translate('hourly')},
                {id: 'daily', value: translate('daily')},
                {id: 'weekly', value: translate('weekly')}
            ];

            $scope.syncPlan = new SyncPlan();
            $scope.syncPlan.interval = $scope.intervals[0].id;
            $scope.syncPlan.startDate = new Date();

            function success(syncPlan) {
                $scope.working = false;
                GlobalNotification.setSuccessMessage(translate('New sync plan successfully created.'));
                $scope.nutupane.refresh();
                if ($scope.product) {
                    $scope.product['sync_plan_id'] = syncPlan.id;
                    $scope.$state.go('product.info', {productId: $scope.product.id});
                } else if ($scope.syncPlanTable) {
                    $scope.syncPlanTable.rows.unshift(syncPlan);
                    $scope.$state.go('sync-plans.details.info', {syncPlanId: syncPlan.id});
                }
            }

            function error(response) {
                $scope.working = false;
                angular.forEach(response.data.errors, function (errors, field) {
                    $scope.syncPlanForm[field].$setValidity('server', false);
                    $scope.syncPlanForm[field].$error.messages = errors;
                });
            }

            $scope.createSyncPlan = function (syncPlan) {
                var GMT_OFFSET_MILLISECONDS = syncPlan.startDate.getTimezoneOffset() * 60000,
                    syncDate = new Date(syncPlan.startDate.getTime() + GMT_OFFSET_MILLISECONDS),
                    syncTime = new Date(syncPlan.startTime || new Date());
                syncDate.setHours(syncTime.getHours());
                syncDate.setMinutes(syncTime.getMinutes());
                syncDate.setSeconds(0);

                syncPlan['sync_date'] = syncDate.toString();
                syncPlan.$save(success, error);
            };
        }]
);
