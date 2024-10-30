/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkSystemPurposeModalController
 *
 * @requires $scope
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires Organization
 * @requires CurrentOrganization
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality for setting system purpose values
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkSystemPurposeModalController',
    ['$scope', '$uibModalInstance', 'HostBulkAction', 'Organization', 'CurrentOrganization', 'Notification', 'hostIds',
    function ($scope, $uibModalInstance, HostBulkAction, Organization, CurrentOrganization, Notification, hostIds) {

        $scope.organization = Organization.get({id: CurrentOrganization});

        $scope.defaultUsages = ['No change', 'None (Clear)', 'Production', 'Development/Test', 'Disaster Recovery'];
        $scope.defaultRoles = ['No change', 'None (Clear)', 'Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation', 'Red Hat Enterprise Linux Compute Node'];
        $scope.defaultServiceLevels = ['No change', 'None (Clear)', 'Self-Support', 'Standard', 'Premium'];

        $scope.hostCount = hostIds.included.ids.length;

        $scope.selectedUsages = $scope.defaultUsages[0];
        $scope.selectedRoles = $scope.defaultRoles[0];
        $scope.selectedServiceLevels = $scope.defaultServiceLevels[0];

        $scope.selectedItemToParam = function (item) {
            var mapping = {
                "None (Clear)": "",
                "No change": null
            };
            if (mapping.hasOwnProperty(item)) {
                return mapping[item];
            }
            return item;
        };

        function actionParams() {
            var params = hostIds;

            params['purpose_usage'] = $scope.selectedItemToParam($scope.selectedUsages);
            params['purpose_role'] = $scope.selectedItemToParam($scope.selectedRoles);
            params['service_level'] = $scope.selectedItemToParam($scope.selectedServiceLevels);

            return params;
        }

        $scope.performAction = function () {
            HostBulkAction.systemPurpose(actionParams(), function (task) {
            $scope.ok();
            $scope.transitionTo('content-hosts.bulk-task', {taskId: task.id});
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
