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
 * @requires Environment
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the available host collection details action pane.
 */
angular.module('Bastion.errata').controller('ErrataContentHostsController',
    ['$scope', 'Nutupane', 'ContentHost', 'Environment', 'CurrentOrganization',
    function ($scope, Nutupane, ContentHost, Environment, CurrentOrganization) {
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'erratum_id': $scope.$stateParams.errataId,
            'organization_id': CurrentOrganization
        };

        if (!params['erratum_id']) {
            params['errata_ids[]'] = _.pluck($scope.table.getSelected(), 'id');
        }

        nutupane = new Nutupane(ContentHost, params);
        nutupane.table.closeItem = function () {};
        nutupane.enableSelectAllResults();

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;

        Environment.queryUnpaged(function (response) {
            $scope.environments = response.results;
        });

        $scope.toggleAvailable = function () {
            nutupane.table.params['erratum_restrict_available'] = $scope.errata.showAvailable;
            nutupane.refresh();
        };

        $scope.selectEnvironment = function (environmentId) {
            params['environment_id'] = environmentId;
            nutupane.setParams(params);
            nutupane.refresh();
        };

        $scope.goToNextStep = function () {
            $scope.$parent.selectedContentHosts = nutupane.getAllSelectedResults();
            if ($scope.errata) {
                $scope.transitionTo('errata.details.apply', {errataId: $scope.errata.id});
            } else {
                $scope.transitionTo('errata.apply.confirm');
            }
        };

        $scope.checkIfIncrementalUpdateRunning();
    }
]);
