/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkTracesController
 *
 * @requires $scope
 * @requires $uibModalInstance
 * @requires HostBulkAction
 * @requires Notification
 * @requires Nutupane
 * @requires BastionConfig
 * @requires hostIds
 * @required ContentHostsHelper
 * @requires translate
 *
 * @description
 *   Provides the functionality to support resolving traces on multiple hosts.
 */
/*jshint camelcase:false*/
angular.module('Bastion.content-hosts').controller('ContentHostsBulkTracesController',
    ['$scope', '$uibModalInstance', 'HostBulkAction', 'Notification', 'Nutupane', 'BastionConfig', 'hostIds', 'ContentHostsHelper', 'translate',
    function ($scope, $uibModalInstance, HostBulkAction, Notification, Nutupane, BastionConfig, hostIds, ContentHostsHelper, translate) {

        var tracesNutupane = new Nutupane(HostBulkAction, hostIds, 'traces');
        tracesNutupane.enableSelectAllResults();
        tracesNutupane.primaryOnly = true;
        $scope.table = tracesNutupane.table;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;

        $scope.performViaRemoteExecution = function() {
            var traceids = _.map($scope.table.getSelected(), 'id');

            var onSuccess = function () {
                var message = translate('Successfully initiated restart of services.');
                Notification.setSuccessMessage(message, {
                    link: {
                        children: translate("View job invocations."),
                        href: "/job_invocations"
                    }});
                $scope.ok();
            };

            var onFailure = function (response) {
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
            };
            /* eslint-disable camelcase */
            HostBulkAction.resolveTraces({trace_ids: traceids}, onSuccess, onFailure);
            /* eslint-enable camelcase */
        };

        $scope.rebootRequired = function() {
            return ContentHostsHelper.rebootRequired($scope.table.getSelected());
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };
    }
]);
