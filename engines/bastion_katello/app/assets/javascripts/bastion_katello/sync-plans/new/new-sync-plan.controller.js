/**
 * @ngdoc object
 * @name  Bastion.sync-plans.controller:NewSyncPlanController
 *
 * @requires $scope
 * @requires translate
 * @requires SyncPlan
 * @requires SyncPlanHelper
 * @requires GlobalNotification
 *
 * @description
 *   Controls the creation of an empty SyncPlan object for use by sub-controllers.
 */
angular.module('Bastion.sync-plans').controller('NewSyncPlanController',
    ['$scope', '$rootScope', 'translate', 'SyncPlan', 'SyncPlanHelper', 'GlobalNotification',
        function ($scope, $rootScope, translate, SyncPlan, SyncPlanHelper, GlobalNotification) {
            $scope.intervals = SyncPlanHelper.getIntervals();

            $scope.syncPlan = new SyncPlan();
            $scope.syncPlan.interval = $scope.intervals[0].id;

            function success(syncPlan) {
                $scope.working = false;
                $scope.$state.go('sync-plan.info', {syncPlanId: syncPlan.id});
                GlobalNotification.setSuccessMessage(translate('New sync plan successfully created.'));
            }

            function error(response) {
                var form = SyncPlanHelper.getForm();

                angular.forEach(response.data.errors, function (errors, field) {
                    form[field].$setValidity('server', false);
                    form[field].$error.messages = errors;
                });

                $scope.working = false;
            }

            $scope.createSyncPlan = function (syncPlan) {
                SyncPlanHelper.createSyncPlan(syncPlan, success, error);
            };

            $scope.setForm = function (form) {
                SyncPlanHelper.setForm(form);
            };
        }]
);
