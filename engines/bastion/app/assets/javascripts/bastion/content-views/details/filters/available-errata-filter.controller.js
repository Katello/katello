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
 * @name  Bastion.content-views.controller:AvailableErrataFilterController
 *
 * @requires $scope
 * @requires gettext
 * @requires Nutupane
 * @requires Filter
 * @requires Rule
 *
 * @description
 *   Handles loading of errata that is available to be added to a filter and provides
 *   functionality to create filter rules based off selected errata.
 */
angular.module('Bastion.content-views').controller('AvailableErrataFilterController',
    ['$scope', 'gettext', 'Nutupane', 'Filter', 'Rule',
    function ($scope, gettext, Nutupane, Filter, Rule) {

        var nutupane;

        nutupane = new Nutupane(
            Filter,
            {filterId: $scope.$stateParams.filterId},
            'availableErrata'
        );

        $scope.errataTable = nutupane.table;

        $scope.addErrata = function (filter) {
            var errataIds = nutupane.getAllSelectedResults('errata_id').included.ids;

            angular.forEach(errataIds, function (erratumId) {
                var rule = new Rule({'errata_id': erratumId});
                saveRule(rule, filter);
            });
        };

        function saveRule(rule, filter) {
            var params = {filterId: filter.id};

            rule.$save(params, success, failure);
        }

        function success(rule) {
            nutupane.removeRow(rule['errata_id'], 'errata_id');
            $scope.successMessages = [gettext('Errata successfully added.')];
        }

        function failure(response) {
            $scope.errorMessages = [response.data.displayMessage];
        }

    }]
);
