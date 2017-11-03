/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostTracesController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostTraces
 * @requires Nutupane
 * @requires BastionConfig
 *
 * @description
 *   Provides the functionality for the content host package list and actions.
 */
/*jshint camelcase:false*/
angular.module('Bastion.content-hosts').controller('ContentHostTracesController',
    ['$scope', '$timeout', '$window', 'translate', 'HostTraces', 'Nutupane', 'BastionConfig',
    function ($scope, $timeout, $window, translate, HostTraces, Nutupane, BastionConfig) {
        var tracesNutupane, params = {
            'paged': true
        };

        tracesNutupane = new Nutupane(HostTraces, params, 'get');
        tracesNutupane.masterOnly = true;
        $scope.table = tracesNutupane.table;
        $scope.table.tracesFilterTerm = "";
        $scope.table.tracesCompare = function (item) {
            var searchText = $scope.table.tracesFilterTerm;
            return item.app_type.indexOf(searchText) >= 0 ||
                item.application.indexOf(searchText) >= 0 ||
                item.helper.indexOf(searchText) >= 0;
        };

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;

        $scope.host.$promise.then(function() {
            if ($scope.host.id) {
                tracesNutupane.setParams({id: $scope.host.id});
                tracesNutupane.load();
            }
        });

        $scope.selectedTraceHelpers = function() {
            var traceHelpers = [],
                selected = $scope.table.getSelected();

            var reboot = selected.some(function(value) {
                return value.app_type === "static";
            });

            if (reboot) {
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
            $scope.traceActionFormValues.hostIds = $scope.host.id;
            $scope.traceActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#traceActionForm').submit();
            }, 0);
        };

    }
]);
