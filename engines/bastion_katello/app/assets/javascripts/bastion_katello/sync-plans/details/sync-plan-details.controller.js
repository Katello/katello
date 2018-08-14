/**
 * @ngdoc object
 * @name  Bastion.sync-plan.controller:SyncPlanDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires SyncPlan
 * @requires ApiErrorHandler
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsController',
    ['$scope', '$state', 'translate', 'SyncPlan', 'ApiErrorHandler', 'Notification',
        function ($scope, $state, translate, SyncPlan, ApiErrorHandler, Notification) {
            $scope.panel = {
                error: false,
                loading: true
            };

            if ($scope.syncPlan) {
                $scope.panel.loading = false;
            }

            $scope.syncPlan = SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function () {
                $scope.panel.loading = false;
            }, function (response) {
                $scope.panel.loading = false;
                ApiErrorHandler.handleGETRequestErrors(response, $scope);
            });

            $scope.runSyncPlan = function () {
                SyncPlan.sync({id: $scope.$stateParams.syncPlanId}, function (task) {
                    $scope.task = task;
                }, function (response) {
                    Notification.setErrorMessage(response.data.errors[0]);
                });
            };

            $scope.removeSyncPlan = function (syncPlan) {
                var syncPlanName = syncPlan.name;
                syncPlan.$remove(function () {
                    Notification.setSuccessMessage(translate('Sync Plan %s has been deleted.').replace('%s', syncPlanName));
                    $scope.transitionTo('sync-plans');
                });
            };
        }
    ]
);
