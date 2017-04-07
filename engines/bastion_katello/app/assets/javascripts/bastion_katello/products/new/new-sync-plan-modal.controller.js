/**
 * @ngdoc object
 * @name  Bastion.proudcts.controller:NewSyncPlanModalController
 *
 * @requires $scope
 * @requires $uibModalInstance
 * @requires SyncPlan
 * @requires SyncPlanHelper
 *
 * @description
 *   A controller for creating a new sync plan in a modal.
 */
angular.module('Bastion.products').controller('NewSyncPlanModalController',
    ['$scope', '$uibModalInstance', 'SyncPlan', 'SyncPlanHelper',
        function ($scope, $uibModalInstance, SyncPlan, SyncPlanHelper) {
            function success(syncPlan) {
                $uibModalInstance.close(syncPlan);
            }

            function error(response) {
                var form = SyncPlanHelper.getForm();

                angular.forEach(response.data.errors, function (errors, field) {
                    form[field].$setValidity('server', false);
                    form[field].$error.messages = errors;
                });
            }

            $scope.ok = function (syncPlan) {
                SyncPlanHelper.createSyncPlan(syncPlan, success, error);
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };

            $scope.isFormDisabled = function () {
                var form = SyncPlanHelper.getForm();
                return form && !form.$valid;
            };

            $scope.intervals = SyncPlanHelper.getIntervals();
            $scope.syncPlan = new SyncPlan();
            $scope.syncPlan.interval = $scope.intervals[0].id;
        }]
);
