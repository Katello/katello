/**
 * @ngdoc object
 * @name  Bastion.sync-plan.controller:SyncPlanDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires SyncPlan
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsController',
    ['$scope', '$state', 'SyncPlan', 'ApiErrorHandler', function ($scope, $state, SyncPlan, ApiErrorHandler) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
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
            var promise;

            promise = $scope.syncPlan.$sync();

            promise.then(function (task) {
                $scope.task = task;
            });

            promise.catch(function (response) {
                $scope.errorMessages = [response.data.errors[0]];
            });
        };
    }]
);
