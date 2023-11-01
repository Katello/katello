/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostModuleStreamsController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostModuleStream
 * @requires Nutupane
 * @requires ModuleStreamActions
 * @requires translate
 *
 * @description
 *   Provides the functionality for the content host module streams list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostModuleStreamsController',
    ['$scope', '$timeout', '$window', 'HostModuleStream', 'Nutupane', 'BastionConfig', 'ModuleStreamActions', 'translate',
    function ($scope, $timeout, $window, HostModuleStream, Nutupane, BastionConfig, ModuleStreamActions, translate) {
        $scope.moduleStreamActions = ModuleStreamActions.getActions();

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Module Streams');

        $scope.working = false;

        $scope.nutupaneParams = { id: $scope.$stateParams.hostId };
        $scope.controllerName = 'katello_host_available_module_streams';

        $scope.moduleStreamsNutupane = new Nutupane(HostModuleStream, $scope.nutupaneParams);

        $scope.moduleStreamsNutupane.primaryOnly = true;
        $scope.table = $scope.moduleStreamsNutupane.table;

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.moduleStreamActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, ''),
            remoteAction: 'module_stream_action'
        };

        $scope.moduleStreamStatus = function(module) {
            var statuses = [];
            if (["enabled", "disabled"].includes(module.status)) {
                statuses.push(translate(_.capitalize(module.status)));
            }
            if (module.installed_profiles.length) {
                statuses.push(translate("Installed"));
            }
            return statuses.join(", ");
        };

        $scope.performViaRemoteExecution = function(moduleSpec, actionType) {
            $scope.working = true;
            $scope.moduleStreamActionFormValues.moduleSpec = moduleSpec;
            $scope.moduleStreamActionFormValues.moduleStreamAction = actionType;
            $scope.moduleStreamActionFormValues.bulkHostIds = angular.toJson({ included: { ids: [$scope.host.id] }});

            $timeout(function () {
                angular.element('#moduleStreamActionForm').submit();
            }, 0);
        };

        $scope.$watch(
          function(scope) {
              return scope.nutupaneParams.status;
          },
          function() {
              $scope.nutupaneParams.page = 1;
              $scope.moduleStreamsNutupane.refresh();
          }
        );
    }
]);
