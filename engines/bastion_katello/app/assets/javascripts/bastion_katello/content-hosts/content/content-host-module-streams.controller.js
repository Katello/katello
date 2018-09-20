/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostModuleStreamsController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires ModuleStream
 * @requires translate
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host module streams list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostModuleStreamsController',
    ['$scope', '$timeout', '$window', 'ModuleStream', 'translate', 'Nutupane', 'BastionConfig',
    function ($scope, $timeout, $window, ModuleStream, translate, Nutupane, BastionConfig) {
        $scope.moduleStreamActions = [
            { action: 'enable', description: translate("Enable")},
            { action: 'disable', description: translate("Disable")},
            { action: 'install', description: translate("Install")},
            { action: 'update', description: translate("Update")},
            { action: 'remove', description: translate("Remove")},
            { action: 'lock', description: translate("Lock")},
            { action: 'unlock', description: translate("Unlock")}
        ];
        $scope.working = false;

        $scope.moduleStreamsNutupane = new Nutupane(ModuleStream, {
            'host_ids': [$scope.$stateParams.hostId],
            'name_stream_only': '1'
        });

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
            $scope.moduleStreamActionFormValues.hostIds = $scope.host.id;

            $timeout(function () {
                angular.element('#moduleStreamActionForm').submit();
            }, 0);
        };
    }
]);
