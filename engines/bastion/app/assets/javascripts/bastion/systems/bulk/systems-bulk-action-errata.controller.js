/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Bastion.systems.controller:SystemsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires SystemBulkAction
 * @requires SystemGroup
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Erratum
 * @requires gettext
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionErrataController',
    ['$scope', '$q', '$location', 'SystemBulkAction', 'SystemGroup', 'Nutupane', 'CurrentOrganization', 'Erratum', 'gettext',
    function ($scope, $q, $location, SystemBulkAction, SystemGroup, Nutupane, CurrentOrganization, Erratum, gettext) {

        var nutupane;

        nutupane = new Nutupane(SystemBulkAction, {}, 'applicableErrata');
        nutupane.table.closeItem = function () {};
        $scope.detailsTable = nutupane.table;
        $scope.detailsTable.errataFilterTerm = "";
        $scope.detailsTable.skipInitialLoad = true;
        $scope.outOfDate = false;
        $scope.initialLoad = true;

        $scope.setState(false, [], []);

        $scope.fetchErrata = function () {
            var params =  $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            nutupane.setParams(params);
            $scope.detailsTable.working = true;
            $scope.outOfDate = false;
            if ($scope.nutupane.anyResultsSelected()) {
                nutupane.refresh().then(function () {
                    $scope.detailsTable.working = false;
                    $scope.outOfDate = false;
                });
            }
            else {
                $scope.detailsTable.working = false;
            }
        };

        $scope.$watch('nutupane.table.rows', function () {
            if ($scope.initialLoad) {
                $scope.initialLoad = false;
                $scope.fetchErrata();
            }
        });

        $scope.$watch('nutupane.table.numSelected', function () {
            if (!$scope.detailsTable.working) {
                $scope.outOfDate = true;
            }
        });

        $scope.transitionToErrata = function (erratum) {
            fetchErratum(erratum['errata_id']);
            $scope.transitionTo('systems.bulk-actions.errata.details', {errataId: erratum['errata_id']});
        };

        $scope.transitionToErrataSystems = function (erratum) {
            $scope.erratum = erratum;
            $scope.transitionTo('systems.bulk-actions.errata.systems', {errataId: erratum['errata_id']});
        };

        $scope.installErrata = function () {
            var params = installParams();
            $scope.setState(true, [], []);
            SystemBulkAction.installContent(params,
                function () {
                    $scope.setState(false, [gettext("Successfully scheduled installation of %s errata .").replace('%s',
                                            params.content.length)], []);
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
