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
 * @name  Bastion.errata.controller:ErrataContentHostsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentHost
 * @requires ContentHostBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the available host collection details action pane.
 */
angular.module('Bastion.errata').controller('ErrataContentHostsController',
    ['$scope', 'translate', 'Nutupane', 'ContentHost', 'ContentHostBulkAction', 'CurrentOrganization',
    function ($scope, translate, Nutupane, ContentHost, ContentHostBulkAction, CurrentOrganization) {
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        nutupane = new Nutupane(ContentHost, params);
        nutupane.table.closeItem = function () {};
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;

        $scope.toggleAvailable = function () {
            nutupane.table.params['erratum_restrict_available'] = $scope.errata.showAvailable;
            nutupane.refresh();
        };
        
        $scope.applyErrata = function () {
            var params = $scope.nutupane.getAllSelectedResults(),
                success, error;

            params['content_type'] = 'errata';
            params.content = [$scope.errata['errata_id']];
            params['organization_id'] = CurrentOrganization;

            success = function () {
                $scope.successMessages = [translate("Successfully scheduled installation of errata")];
                $scope.nutupane.refresh();
            };

            error = function (data) {
                $scope.errorMessages = data.errors;
            };

            ContentHostBulkAction.installContent(params, success, error);
        };
    }
]);
