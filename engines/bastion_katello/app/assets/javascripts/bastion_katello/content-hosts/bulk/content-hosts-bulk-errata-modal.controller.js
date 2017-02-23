/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkErrataModalController
 *
 * @requires $scope
 * @requires $http
 * @requires $location
 * @requires $window
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires HostCollection
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Erratum
 * @requires GlobalNotification
 * @requires BastionConfig
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkErrataModalController',
    ['$scope', '$http', '$location', '$window', '$uibModalInstance', 'HostBulkAction', 'HostCollection', 'Nutupane', 'CurrentOrganization', 'Erratum', 'GlobalNotification', 'BastionConfig', 'hostIds',
    function ($scope, $http, $location, $window, $uibModalInstance, HostBulkAction, HostCollection, Nutupane, CurrentOrganization, Erratum, GlobalNotification, BastionConfig, hostIds) {
        var nutupane;

        function installParams() {
            var params = hostIds;
            params['content_type'] = 'errata';
            params.content = _.map($scope.table.getSelected(), 'errata_id');
            params['organization_id'] = CurrentOrganization;
            return params;
        }

        function fetchErratum(errataId) {
            $scope.erratum = Erratum.get({id: errataId, 'organization_id': CurrentOrganization});
        }

        nutupane = new Nutupane(HostBulkAction, {}, 'installableErrata');
        $scope.controllerName = 'katello_errata';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.table.errataFilterTerm = "";
        $scope.table.initialLoad = false;
        $scope.initialLoad = true;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;

        $scope.fetchErrata = function () {
            var params = hostIds;
            params['organization_id'] = CurrentOrganization;
            nutupane.setParams(params);
            $scope.table.working = true;
            if ($scope.table.numSelected > 0) {
                nutupane.refresh().then(function () {
                    $scope.table.working = false;
                });
            } else {
                $scope.table.working = false;
            }
        };

        $scope.transitionToErrata = function (erratum) {
            fetchErratum(erratum['errata_id']);
            $scope.transitionTo('content-hosts.bulk-actions.errata.details', {errataId: erratum['errata_id']});
        };

        $scope.transitionToErrataContentHosts = function (erratum) {
            $scope.erratum = erratum;
            $scope.transitionTo('content-hosts.bulk-actions.errata.content-hosts', {errataId: erratum['errata_id']});
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
                    nutupane.invalidate();
                    $scope.ok();
                    $scope.transitionTo('content-hosts.bulk-task', {taskId: data.id});
                },
                function (response) {
                    angular.forEach(response.data.errors, function (error) {
                        GlobalNotification.setErrorMessage(error);
                    });
                });
        };

        $scope.installErrataViaRemoteExecution = function(customize) {
            var formData = {},
                errataIds = _.map($scope.table.getSelected(), 'errata_id'),
                selectedHosts = hostIds;

            formData.authenticityToken = $window.AUTH_TOKEN.replace(/&quot;/g, '');
            formData.remoteAction = 'errata_install';
            formData.errata = errataIds.join(',');
            formData.hostIds = selectedHosts.included.ids.join(',');
            formData.search = selectedHosts.included.search;
            formData.customize = customize;

            $http.post('/katello/remote_execution', formData, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded'
            }});
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
