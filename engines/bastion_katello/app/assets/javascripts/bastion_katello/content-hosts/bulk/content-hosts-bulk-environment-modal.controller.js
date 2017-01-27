/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkEnvironmentModalController
 *
 * @requires $scope
 * @requires $state
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality for setting content view and environment
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkEnvironmentModalController',
    ['$scope', '$state', '$uibModalInstance', 'HostBulkAction', 'Organization', 'CurrentOrganization', 'ContentView', 'Notification', 'hostIds',
    function ($scope, $state, $uibModalInstance, HostBulkAction, Organization, CurrentOrganization, ContentView, Notification, hostIds) {

        function actionParams() {
            var params = hostIds;
            params['organization_id'] = CurrentOrganization;
            params['environment_id'] = $scope.selected.environment.id;
            params['content_view_id'] = $scope.selected.contentView.id;
            return params;
        }

        $scope.selected = {
            environment: undefined,
            contentView: undefined
        };

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.disableAssignButton = function (confirm) {
            return confirm || hostIds === 0 ||
                angular.isUndefined($scope.selected.environment) || angular.isUndefined($scope.selected.contentView);
        };

        $scope.$watch('selected.environment', function (environment) {
            if (environment) {
                $scope.fetchViews();
            }
        });

        $scope.fetchViews = function () {
            $scope.fetchingContentViews = true;

            ContentView.queryUnpaged({ 'environment_id': $scope.selected.environment.id }, function (response) {
                $scope.contentViews = response.results;
                $scope.fetchingContentViews = false;
            });
        };

        $scope.performAction = function () {
            HostBulkAction.environmentContentView(actionParams(), function (task) {
                $scope.ok();
                $state.go('content-hosts.bulk-task', {taskId: task.id});
            }, function (response) {
                angular.forEach(response.data.errors, function (error) {
                    Notification.setErrorMessage(error);
                });
            });
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };
    }]
);
