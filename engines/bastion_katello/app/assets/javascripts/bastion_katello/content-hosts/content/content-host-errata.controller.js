/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostErrataController
 *
 * @requires $scope
 * @requires ContentHostErratum
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host package list and actions.
 */
/*jshint camelcase:false*/
angular.module('Bastion.content-hosts').controller('ContentHostErrataController',
    ['$scope', 'translate', 'ContentHostErratum', 'Nutupane', 'Organization', 'Environment',
    function ($scope, translate, ContentHostErratum, Nutupane, Organization, Environment) {
        var errataNutupane = new Nutupane(ContentHostErratum, {'id': $scope.$stateParams.contentHostId, searchTerm: $scope.$stateParams.search}, 'get');

        errataNutupane.masterOnly = true;
        $scope.detailsTable = errataNutupane.table;
        $scope.detailsTable.errataFilterTerm = "";
        $scope.detailsTable.errataCompare = function (item) {
            var searchText = $scope.detailsTable.errataFilterTerm;
            return item.type.indexOf(searchText)  >= 0 ||
                item.errata_id.indexOf(searchText) >= 0 ||
                item.title.indexOf(searchText) >= 0;
        };

        $scope.selectedErrataOption = 'current';
        $scope.errataOptions = [{name: "Current Environment", label: 'current'}, {name: 'foo', label: 'bar'}];

        $scope.setupErrataOptions = function (host) {
            var libraryString = translate("Library Synced Content"),
                currentEnv = translate("Current Environment (%e/%cv)").replace("%e", host.environment.name).replace("%cv", host.content_view.name),
                previousEnv;

            $scope.errataOptions = [{name: currentEnv, label: 'current', order: 3}];

            if (!host.environment.library) {
                Environment.get({id: host.environment.id}).$promise.then(function (env) {
                    previousEnv = translate("Previous Environment (%e/%cv)").replace('%e', env.prior.name).replace("%cv", host.content_view.name);
                    $scope.errataOptions.push({name: previousEnv,
                        label: 'prior', order: 2, 'content_view_id': host.content_view_id, 'environment_id': env.prior.id});

                });
            }
            if (!host.content_view.default) {
                Organization.get({id: host.environment.organization.id}).$promise.then(function (org) {
                    $scope.errataOptions.push({name: libraryString, label: 'library', order: 1,
                        'content_view_id': org.default_content_view_id, 'environment_id': org.library_id});
                });
            }
        };
        $scope.contentHost.$promise.then($scope.setupErrataOptions);

        $scope.refreshErrata = function (selected) {
            var option, params;
            params = {'id': $scope.$stateParams.contentHostId};

            $scope.selectedErrataOption = selected;

            if (selected === 'library' || selected === 'prior') {
                option = _.find($scope.errataOptions, function (option) {return option.label === selected});
                params['content_view_id'] = option['content_view_id'];
                params['environment_id'] = option['environment_id'];
            }

            errataNutupane.setParams(params);
            errataNutupane.refresh();
        };

        $scope.transitionToErratum = function (erratum) {
            loadErratum(erratum.errata_id);
            $scope.transitionTo('content-hosts.details.errata.details', {errataId: erratum.errata_id});
        };

        $scope.applySelected = function () {
            var selected, errataIds = [];
            selected = $scope.detailsTable.getSelected();
            if (selected.length > 0) {
                angular.forEach(selected, function (value) {
                    errataIds.push(value.errata_id);
                });
                ContentHostErratum.apply({uuid: $scope.contentHost.uuid, errata_ids: errataIds},
                                   function (task) {
                                        $scope.detailsTable.selectAll(false);
                                        $scope.transitionTo('content-hosts.details.tasks.details', {taskId: task.id});
                                    });
            }
        };

        function loadErratum(errataId) {
            $scope.erratum = ContentHostErratum.get({'id': $scope.$stateParams.contentHostId,
                'errata_id': errataId});
        }

        if ($scope.$stateParams.errataId) {
            loadErratum($scope.$stateParams.errataId);
        }
    }
]);
