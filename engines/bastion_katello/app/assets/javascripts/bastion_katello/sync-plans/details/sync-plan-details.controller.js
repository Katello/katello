/**
 * @ngdoc object
 * @name  Bastion.sync-plan.controller:SyncPlanDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires SyncPlan
 *
 * @description
 *   Provides the functionality for the sync plan details action pane.
 */
angular.module('Bastion.sync-plans').controller('SyncPlanDetailsController',
    ['$scope', '$state', 'SyncPlan', function ($scope, $state, SyncPlan) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.syncPlan) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.syncPlan = SyncPlan.get({id: $scope.$stateParams.syncPlanId}, function () {
            $scope.panel.loading = false;
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
