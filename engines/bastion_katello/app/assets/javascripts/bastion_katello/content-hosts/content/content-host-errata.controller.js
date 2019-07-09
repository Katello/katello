/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostErrataController
 *
 * @requires $scope
 * @resource $timeout
 * @resource $window
 * @requires HostErratum
 * @requires Nutupane
 * @requires BastionConfig
 *
 * @description
 *   Provides the functionality for the content host package list and actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostErrataController',
    ['$scope', '$timeout', '$window', 'translate', 'HostErratum', 'Nutupane', 'Organization', 'Environment', 'BastionConfig',
    function ($scope, $timeout, $window, translate, HostErratum, Nutupane, Organization, Environment, BastionConfig) {
        var params = {
            'sort_by': 'updated',
            'sort_order': 'DESC',
            'paged': true,
            'errata_restrict_applicable': true,
            'id': $scope.$stateParams.hostId
        };

        function loadErratum(errataId) {
            $scope.erratum = HostErratum.get({'id': $scope.host.id,
                'errata_id': errataId});
        }

        $scope.nutupane = new Nutupane(HostErratum, params, 'get');
        $scope.controllerName = 'katello_errata';
        $scope.nutupane.masterOnly = true;
        $scope.table = $scope.nutupane.table;
        $scope.table.errataFilterTerm = "";

        $scope.table.errataCompare = function (item) {
            var searchText = $scope.table.errataFilterTerm;
            return item.type.indexOf(searchText) >= 0 ||
                item['errata_id'].indexOf(searchText) >= 0 ||
                item.title.indexOf(searchText) >= 0;
        };

        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.remoteExecutionByDefault = BastionConfig.remoteExecutionByDefault;
        $scope.errataActionFormValues = {
            authenticityToken: $window.AUTH_TOKEN.replace(/&quot;/g, '')
        };

        $scope.selectedErrataOption = 'current';
        $scope.errataOptions = [{name: "Current Lifecycle Environment", label: 'current'}, {name: 'foo', label: 'bar'}];

        $scope.table.initialLoad = false;

        $scope.setupErrataOptions = function (host) {
            var libraryString = translate("Library Synced Content"),
                currentEnv,
                previousEnv;

            if (host.hasContent()) {
                currentEnv = translate("Current Lifecycle Environment (%e/%cv)").replace("%e", host.content_facet_attributes.lifecycle_environment.name).replace("%cv", host.content_facet_attributes.content_view_name);
                $scope.errataOptions = [{name: currentEnv, label: 'current', order: 3}];

                if (!host['content_facet_attributes']['lifecycle_environment_library?']) {
                    Environment.get({id: host['content_facet_attributes'].lifecycle_environment.id}).$promise.then(function (env) {
                        previousEnv = translate("Previous Lifecycle Environment (%e/%cv)").replace('%e', env.prior.name).replace("%cv", host.content_facet_attributes.content_view_name);
                        $scope.errataOptions.push({name: previousEnv,
                                                   label: 'prior', order: 2, 'content_view_id': host.content_facet_attributes.content_view_id, 'environment_id': env.prior.id});

                    });
                }
                if (!host.content_facet_attributes['content_view_default?']) {
                    Organization.get({id: host['organization_id']}).$promise.then(function (org) {
                        $scope.errataOptions.push({name: libraryString, label: 'library', order: 1,
                                                   'content_view_id': org['default_content_view_id'], 'environment_id': org.library_id});
                    });
                }
            }
        };

        $scope.host.$promise.then(function() {
            $scope.setupErrataOptions($scope.host);
            if ($scope.host['content_facet_attributes'] && $scope.host.id) {
                $scope.nutupane.setParams({id: $scope.host.id});
                $scope.nutupane.load();
            }
        });

        $scope.calculateApplicability = function () {
            $scope.calculatingApplicability = true;
            HostErratum.regenerateApplicability({id: $scope.host.id},
                function (task) {
                    $scope.transitionTo('content-host.tasks.details', {taskId: task.id});
                }, function() {
                    $scope.calculatingApplicability = false;
                });
        };

        $scope.refreshErrata = function (selected) {
            var option, errataParams;
            errataParams = {'id': $scope.host.id};
            $scope.selectedErrataOption = selected;

            if (selected === 'library' || selected === 'prior') {
                option = _.find($scope.errataOptions, function (opt) {
                    return opt.label === selected;
                });
                errataParams['content_view_id'] = option['content_view_id'];
                errataParams['environment_id'] = option['environment_id'];
            }

            $scope.nutupane.setParams(errataParams);
            $scope.nutupane.refresh();
        };

        $scope.transitionToErratum = function (erratum) {
            loadErratum(erratum['errata_id']);
            $scope.transitionTo('content-host.errata.details', {errataId: erratum.errata_id});
        };

        $scope.selectedErrataIds = function () {
            return $scope.nutupane.getAllSelectedResults('errata_id');
        };

        $scope.performViaKatelloAgent = function () {
            var errataIds = $scope.selectedErrataIds();
            HostErratum.apply({id: $scope.host.id, 'bulk_errata_ids': errataIds},
                               function (task) {
                                    $scope.table.selectAll(false);
                                    $scope.transitionTo('content-host.tasks.details', {taskId: task.id});
                                });
        };

        $scope.performViaRemoteExecution = function(customize) {
            var errataIds = $scope.selectedErrataIds();
            $scope.errataActionFormValues.errata = errataIds.included.ids.join(',');
            $scope.errataActionFormValues.hostIds = $scope.host.id;
            $scope.errataActionFormValues.customize = customize;

            $timeout(function () {
                angular.element('#errataActionForm').submit();
            }, 0);
        };

        $scope.applySelected = function () {
            if ($scope.remoteExecutionByDefault) {
                $scope.performViaRemoteExecution(false);
            } else {
                $scope.performViaKatelloAgent();
            }
        };

        $scope.nutupane.enableSelectAllResults();

        if ($scope.$stateParams.errataId) {
            loadErratum($scope.$stateParams.errataId);
        }
    }
]);
