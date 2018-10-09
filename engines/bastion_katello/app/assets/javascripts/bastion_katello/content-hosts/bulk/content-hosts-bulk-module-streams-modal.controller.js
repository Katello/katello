/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkModuleStreamsModalController
 *
 * @requires $scope
 * @requires $window
 * @requires $timeout
 * @requires $uibModalInstance
 * @requires ModuleStream
 * @requires Nutupane
 * @requires hostIds
 * @requires ModuleStreamActions
 *
 * @description
 *   Provides the functionality for the content host module streams list and actions.
 */

angular.module('Bastion.content-hosts').controller('ContentHostsBulkModuleStreamsModalController',
    ['$scope', '$window', '$timeout', '$uibModalInstance', 'ModuleStream', 'Nutupane', 'BastionConfig',
     'hostIds', 'ModuleStreamActions',
    function ($scope, $window, $timeout, $uibModalInstance, ModuleStream, Nutupane,
              BastionConfig, hostIds, ModuleStreamActions) {
        var nutupaneParams;

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };

        $scope.moduleStreamActions = ModuleStreamActions.getActions();

        $scope.working = false;

        nutupaneParams = { 'name_stream_only': '1' };

        $scope.moduleStreamsNutupane = new Nutupane(ModuleStream, Object.assign(
            nutupaneParams,
            hostIds
        ));
        $scope.controllerName = 'katello_module_streams';
        $scope.moduleStreamsNutupane.masterOnly = true;
        $scope.table = $scope.moduleStreamsNutupane.table;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;

        $scope.moduleStreamActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, ''),
            remoteAction: 'module_stream_action',
            search: hostIds.included.search
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
        console.log(hostIds);
    }
  ]
);