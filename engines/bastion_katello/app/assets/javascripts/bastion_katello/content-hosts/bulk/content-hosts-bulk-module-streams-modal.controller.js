/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkModuleStreamsModalController
 *
 * @requires $scope
 * @requires $window
 * @requires $timeout
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires Nutupane
 * @requires BastionConfig
 * @requires hostIds
 * @requires ModuleStreamActions
 *
 * @description
 *   Provides the functionality for the content host module streams list and actions.
 */

angular.module('Bastion.content-hosts').controller('ContentHostsBulkModuleStreamsModalController',
    ['$scope', '$window', '$timeout', '$uibModalInstance', 'HostBulkAction', 'Nutupane', 'BastionConfig',
     'hostIds', 'ModuleStreamActions',
    function ($scope, $window, $timeout, $uibModalInstance, HostBulkAction, Nutupane,
              BastionConfig, hostIds, ModuleStreamActions) {
        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };

        $scope.moduleStreamActions = ModuleStreamActions.getActions();

        $scope.working = false;

        $scope.moduleStreamsNutupane = new Nutupane(HostBulkAction, hostIds, 'moduleStreams');
        $scope.controllerName = 'katello_module_streams';
        $scope.moduleStreamsNutupane.masterOnly = true;
        $scope.table = $scope.moduleStreamsNutupane.table;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;

        $scope.moduleStreamActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, ''),
            remoteAction: 'module_stream_action'
        };

        if (hostIds.included.ids) {
            $scope.moduleStreamActionFormValues.hostIds = hostIds.included.ids.join(',');
        }

        $scope.performViaRemoteExecution = function(moduleSpec, actionType) {
            $scope.working = true;
            $scope.moduleStreamActionFormValues.moduleSpec = moduleSpec;
            $scope.moduleStreamActionFormValues.moduleStreamAction = actionType;

            $timeout(function () {
                angular.element('#moduleStreamActionForm').submit();
            }, 0);
        };
    }
  ]
);
