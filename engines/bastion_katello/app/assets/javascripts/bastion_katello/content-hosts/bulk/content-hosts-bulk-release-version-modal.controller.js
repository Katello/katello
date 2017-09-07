/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkReleaseVersionModalController
 *
 * @requires $scope
 * @requires $state
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires Organization
 * @requires CurrentOrganization
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality for setting content view and environment
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkReleaseVersionModalController',
    ['$scope', '$state', '$uibModalInstance', 'HostBulkAction', 'Organization', 'CurrentOrganization', 'Notification', 'hostIds',
    function ($scope, $state, $uibModalInstance, HostBulkAction, Organization, CurrentOrganization, Notification, hostIds) {

        function actionParams() {
            var params = hostIds;
            params['organization_id'] = CurrentOrganization;
            params['release_version'] = $scope.selected.release;

            return params;
        }

        $scope.selected = {
            release: undefined
        };
        $scope.fetchingReleases = true;

        Organization.releaseVersions({id: CurrentOrganization}, function (response) {
            $scope.releases = response.results;
            $scope.fetchingReleases = false;
        });

        $scope.disableAssignButton = function (confirm) {
            return confirm || hostIds === 0 || angular.isUndefined($scope.selected.release);
        };

        $scope.performAction = function () {
            HostBulkAction.releaseVersion(actionParams(), function (task) {
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
