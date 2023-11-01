/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostTracesController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires translate
 * @requires HostTraces
 * @requires Nutupane
 * @requires BastionConfig
 * @required ContentHostsHelper
 *
 * @description
 *   Provides the functionality for the content host package list and actions.
 */
/*jshint camelcase:false*/
angular.module('Bastion.content-hosts').controller('ContentHostTracesController',
    ['$scope', '$timeout', '$window', 'translate', 'HostTraces', 'Nutupane', 'BastionConfig', 'ContentHostsHelper',
    function ($scope, $timeout, $window, translate, HostTraces, Nutupane, BastionConfig, ContentHostsHelper) {
        var tracesNutupane, params = {
            'paged': true
        };

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Traces');

        tracesNutupane = new Nutupane(HostTraces, params, 'get', {'disableAutoLoad': true});
        tracesNutupane.primaryOnly = true;
        $scope.controllerName = 'katello_host_tracers';
        $scope.table = tracesNutupane.table;
        $scope.table.tracesFilterTerm = "";
        $scope.table.tracesCompare = function (item) {
            var searchText = $scope.table.tracesFilterTerm;
            return item.app_type.indexOf(searchText) >= 0 ||
                item.application.indexOf(searchText) >= 0 ||
                item.helper.indexOf(searchText) >= 0;
        };

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;

        $scope.rebootRequired = function() {
            return ContentHostsHelper.rebootRequired($scope.table.getSelected());
        };

        $scope.host.$promise.then(function() {
            if ($scope.host.id) {
                tracesNutupane.setParams({id: $scope.host.id});
                tracesNutupane.load();
            }
            $scope.host.rebootRequired = $scope.rebootRequired;
        });

        $scope.selectedTraceHelpers = function() {
            var traceHelpers = [],
                selected = $scope.table.getSelected();

            if ($scope.rebootRequired()) {
                return ["reboot"];
            }

            selected.forEach(function(value) {
                if (value.app_type !== "session") {
                    if (traceHelpers.indexOf(value.helper) === -1) {
                        traceHelpers.push(value.helper);
                    }
                }
            });
            return traceHelpers;
        };

        $scope.traceActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.performViaRemoteExecution = function(customize) {
            var traceHelpers = $scope.selectedTraceHelpers();
            $scope.traceActionFormValues.helper = $.grep(traceHelpers, Boolean).join(',');
            $scope.traceActionFormValues.bulkHostIds = angular.toJson({ included: { ids: [$scope.host.id] }});
            $scope.traceActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#traceActionForm').submit();
            }, 0);
        };
    }
]);
