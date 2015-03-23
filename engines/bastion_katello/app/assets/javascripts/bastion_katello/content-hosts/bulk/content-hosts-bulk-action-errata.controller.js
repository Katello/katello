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
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires ContentHostBulkAction
 * @requires HostCollection
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Erratum
 * @requires translate
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionErrataController',
    ['$scope', '$q', '$location', 'ContentHostBulkAction', 'HostCollection', 'Nutupane', 'CurrentOrganization', 'Erratum',
    function ($scope, $q, $location, ContentHostBulkAction, HostCollection, Nutupane, CurrentOrganization, Erratum) {

        var nutupane;

        nutupane = new Nutupane(ContentHostBulkAction, {}, 'applicableErrata');
        nutupane.table.closeItem = function () {};
        $scope.detailsTable = nutupane.table;
        $scope.detailsTable.errataFilterTerm = "";
        $scope.detailsTable.initialLoad = false;
        $scope.outOfDate = false;
        $scope.initialLoad = true;

        $scope.setState(false, [], []);

        $scope.fetchErrata = function () {
            var params =  $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            nutupane.setParams(params);
            $scope.detailsTable.working = true;
            $scope.outOfDate = false;
            if ($scope.table.numSelected > 0) {
                nutupane.refresh().then(function () {
                    $scope.detailsTable.working = false;
                    $scope.outOfDate = false;
                });
            }
            else {
                $scope.detailsTable.working = false;
            }
        };

        $scope.$watch('nutupane.table.rows', function (rows) {
            if ($scope.initialLoad && rows.length > 0) {
                $scope.initialLoad = false;
                $scope.fetchErrata();
            }
        });

        $scope.$watch('nutupane.table.numSelected', function (numSelected) {
            if ((numSelected > 0) && !$scope.detailsTable.working) {
                $scope.outOfDate = true;
            }
        });

        $scope.transitionToErrata = function (erratum) {
            fetchErratum(erratum['errata_id']);
            $scope.transitionTo('content-hosts.bulk-actions.errata.details', {errataId: erratum['errata_id']});
        };

        $scope.transitionToErrataContentHosts = function (erratum) {
            $scope.erratum = erratum;
            $scope.transitionTo('content-hosts.bulk-actions.errata.content-hosts', {errataId: erratum['errata_id']});
        };

        $scope.installErrata = function () {
            var params = installParams();
            $scope.setState(true, [], []);
            ContentHostBulkAction.installContent(params,
                function (data) {
                    $scope.setState(false, [], []);
                    $scope.transitionTo('content-hosts.bulk-actions.task-details', {taskId: data.id});
                },
                function (data) {
                    $scope.setState(false, [], data.errors);
                });
        };

        function installParams() {
            var params = $scope.nutupane.getAllSelectedResults();
            params['content_type'] = 'errata';
            params.content = _.pluck($scope.detailsTable.getSelected(), 'errata_id');
            params['organization_id'] = CurrentOrganization;
            return params;
        }

        function fetchErratum(errataId) {
            $scope.erratum = Erratum.get({id: errataId, 'organization_id': CurrentOrganization});
        }

    }]
);
