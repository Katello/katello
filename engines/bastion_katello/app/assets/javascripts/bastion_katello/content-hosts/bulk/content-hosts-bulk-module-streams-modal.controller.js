/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkModuleStreamsModalController
 *
 * @requires $scope
 * @requires $http
 * @requires $location
 * @requires $window
 * @requires $timeout
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires HostCollection
 * @requires ModuleStream
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Notification
 * @requires BastionConfig
 * @requires hostIds
 * @requires translate
 *
 * @description
 *   Provides the functionality for the content host module streams list and actions.
 */

angular.module('Bastion.content-hosts').controller('ContentHostsBulkModuleStreamsModalController',
    ['$scope', '$http', '$location', '$window', '$timeout', '$uibModalInstance', 'HostBulkAction',
     'HostCollection', 'ModuleStream', 'Nutupane', 'CurrentOrganization', 'Notification', 'BastionConfig',
     'hostIds', 'translate',
    function ($scope, $http, $location, $window, $timeout, $uibModalInstance, HostBulkAction, HostCollection,
              ModuleStream, Nutupane, CurrentOrganization, Notification, BastionConfig, hostIds, translate) {
        var nutupaneParams;

        console.log(hostIds);

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };

        $scope.moduleStreamActions = [
          { action: 'enable', description: translate("Enable")},
          { action: 'disable', description: translate("Disable")},
          { action: 'install', description: translate("Install")},
          { action: 'update', description: translate("Update")},
          { action: 'remove', description: translate("Remove")}
        ];

        $scope.working = false;

        nutupaneParams = { 'name_stream_only': '1' };

        console.log(hostIds.included.ids);
        if (hostIds.included.ids) {
          nutupaneParams['host_ids'] = hostIds.included.ids.join(',');
        } else {
          nutupaneParams['host_collection_id'] = $scope.$stateParams.hostCollectionId;
        }

        $scope.moduleStreamsNutupane = new Nutupane(ModuleStream, nutupaneParams);

        $scope.moduleStreamsNutupane.masterOnly = true;
        $scope.table = $scope.moduleStreamsNutupane.table;

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.moduleStreamActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, ''),
            remoteAction: 'module_stream_action'
        };

        $scope.performViaRemoteExecution = function(moduleSpec, actionType) {
            $scope.working = true;
            $scope.moduleStreamActionFormValues.moduleSpec = moduleSpec;
            $scope.moduleStreamActionFormValues.moduleStreamAction = actionType;

            if ($scope.$stateParams && $scope.$stateParams.hostCollectionId) {
              $scope.moduleStreamActionFormValues.hostCollectionId = $scope.$stateParams.hostCollectionId;
            } else if (hostIds.included.ids) {
              $scope.moduleStreamActionFormValues.hostIds = hostIds.included.ids.join(',');
            };

            $timeout(function () {
                angular.element('#moduleStreamActionForm').submit();
            }, 0);
        };
    }
  ]
);