/**
 * @ngdoc object
 * @name  Bastion.sync-plans.controller:NewSyncPlanController
 *
 * @requires $scope
 * @requires translate
 * @requires SyncPlan
 * @requires SyncPlanHelper
 * @requires Notification
 *
 * @description
 *   Controls the creation of an empty SyncPlan object for use by sub-controllers.
 */
angular.module('Bastion.sync-plans').controller('NewSyncPlanController',
    ['$scope', '$rootScope', 'translate', 'SyncPlan', 'SyncPlanHelper', 'Notification',
        function ($scope, $rootScope, translate, SyncPlan, SyncPlanHelper, Notification) {
            $scope.intervals = SyncPlanHelper.getIntervals();

            $scope.syncPlan = new SyncPlan();
            $scope.syncPlan.interval = $scope.intervals[0].id;
            $scope.syncPlan.startDate = new Date();
            $scope.isWorking = false;

            function success(syncPlan) {
                $scope.isWorking = false;
                $scope.$state.go('sync-plan.info', {syncPlanId: syncPlan.id});
                Notification.setSuccessMessage(translate('New sync plan successfully created.'));
            }

            function error(response) {
                var form = SyncPlanHelper.getForm();
                $scope.isWorking = false;
                angular.forEach(response.data.errors, function (errors, field) {
                    if (form[field]) {
                        form[field].$setValidity('server', false);
                        form[field].$error.messages = errors;
                    } else {
                        Notification.setErrorMessage("Error saving the Sync Plan: " + " " + errors);
                    }
                });
            }

            $scope.createSyncPlan = function (syncPlan) {
                $scope.isWorking = true;
                SyncPlanHelper.createSyncPlan(syncPlan, success, error);
            };

            $scope.setForm = function (form) {
                SyncPlanHelper.setForm(form);
            };
        }]
);
