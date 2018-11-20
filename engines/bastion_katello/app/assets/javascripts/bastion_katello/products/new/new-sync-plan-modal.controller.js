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
    ['$scope', '$uibModalInstance', 'SyncPlan', 'SyncPlanHelper', 'Notification', 'translate',
        function ($scope, $uibModalInstance, SyncPlan, SyncPlanHelper, Notification, translate) {
            function success(syncPlan) {
                Notification.setSuccessMessage(translate("Sync Plan saved"));
                $scope.isWorking = false;
                $uibModalInstance.close(syncPlan);
            }

            function error(response) {
                var form = SyncPlanHelper.getForm();
                $scope.isWorking = false;
                angular.forEach(response.data.errors, function (errors, field) {
                    if (form[field]) {
                        form[field].$setValidity('server', false);
                        form[field].$error.messages = errors;
                    } else {
                        Notification.setErrorMessage(translate("Error saving the Sync Plan: " + " " + errors));
                    }
                });
            }

            $scope.ok = function (syncPlan) {
                $scope.isWorking = true;
                SyncPlanHelper.createSyncPlan(syncPlan, success, error);
            };

            $scope.cancel = function () {
                $scope.isWorking = true;
                $uibModalInstance.dismiss('cancel');
            };

            $scope.isFormDisabled = function () {
                var form = SyncPlanHelper.getForm();
                return form && $scope.isWorking;
            };

            $scope.intervals = SyncPlanHelper.getIntervals();
            $scope.syncPlan = new SyncPlan();
            $scope.syncPlan.interval = $scope.intervals[0].id;
        }]
);
