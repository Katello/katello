/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkErrataModalController
 *
 * @requires $scope
 * @requires $http
 * @requires $location
 * @requires $window
 * @requires $timeout
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires HostCollection
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Erratum
 * @requires Notification
 * @requires BastionConfig
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkErrataModalController',
    ['$scope', '$http', '$location', '$window', '$timeout', '$uibModalInstance', 'HostBulkAction', 'HostCollection', 'Nutupane', 'CurrentOrganization', 'Erratum', 'Notification', 'BastionConfig', 'hostIds',
    function ($scope, $http, $location, $window, $timeout, $uibModalInstance, HostBulkAction, HostCollection, Nutupane, CurrentOrganization, Erratum, Notification, BastionConfig, hostIds) {
        function installParams() {
            var params = hostIds;
            params['content_type'] = 'errata';
            params.content = _.map($scope.table.getSelected(), 'errata_id');

            if ($scope.nutupane.table.allResultsSelected) {
                params['install_all'] = true;
            } else {
                params['install_all'] = false;
            }

            params['organization_id'] = CurrentOrganization;
            return params;
        }

        function fetchErratum(errataId) {
            $scope.erratum = Erratum.get({id: errataId, 'organization_id': CurrentOrganization});
        }

        $scope.nutupane = new Nutupane(HostBulkAction, hostIds, 'installableErrata');
        $scope.nutupane.enableSelectAllResults();

        $scope.controllerName = 'katello_errata';
        $scope.nutupane.primaryOnly = true;
        $scope.showErrata = false;
        $scope.showHosts = false;
        $scope.table = $scope.nutupane.table;
        $scope.table.errataFilterTerm = "";
        $scope.table.initialLoad = false;
        $scope.initialLoad = true;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.katelloAgentPresent = BastionConfig.katelloAgentPresent;
        $scope.allHostsSelected = hostIds.allResultsSelected;
        $scope.hostToolingEnabled = BastionConfig.hostToolingEnabled;

        $scope.errataActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.errataActionFormValues.bulkHostIds = angular.toJson(hostIds);

        $scope.showTable = function () {
            return (!$scope.showErrata && !$scope.showHosts);
        };

        $scope.fetchErrata = function () {
            var params = hostIds;
            params['organization_id'] = CurrentOrganization;
            $scope.nutupane.setParams(params);
            $scope.table.working = true;
            if ($scope.table.numSelected > 0) {
                $scope.nutupane.refresh().then(function () {
                    $scope.table.working = false;
                });
            } else {
                $scope.table.working = false;
            }
        };

        $scope.transitionToErrata = function (erratum) {
            fetchErratum(erratum['errata_id']);
            $scope.erratum = erratum;
            $scope.showErrata = true;
        };

        $scope.installErrata = function () {
            if ($scope.remoteExecutionByDefault) {
                $scope.installErrataViaRemoteExecution();

            } else {
                $scope.installErrataViaKatelloAgent(false);
            }
        };

        $scope.installErrataViaKatelloAgent = function () {
            var params = installParams();
            HostBulkAction.installContent(params,
              function (data) {
                  $scope.nutupane.invalidate();
                  $scope.ok();
                  $scope.transitionTo('content-hosts.bulk-task', {taskId: data.id});
              },
              function (response) {
                  angular.forEach(response.data.errors, function (error) {
                      Notification.setErrorMessage(error);
                  });
              });
        };

        $scope.selectedErrataIds = function () {
            return $scope.nutupane.getAllSelectedResults('errata_id');
        };

        $scope.installErrataViaRemoteExecution = function(customize) {
            var errataIds = $scope.selectedErrataIds();
            $scope.errataActionFormValues.bulkErrataIds = angular.toJson(errataIds);

            $scope.errataActionFormValues.remoteAction = 'errata_install';
            $scope.errataActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#errataActionForm').submit();
            }, 0);
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };

        $scope.fetchErrata();
    }]
);
