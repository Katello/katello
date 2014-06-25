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
 * @requires translate
 * @requires Nutupane
 * @requires Filter
 * @requires Rule
 *
 * @description
 *   Handles loading of errata that is available to be added to a filter and provides
 *   functionality to create filter rules based off selected errata.
 */
angular.module('Bastion.content-views').controller('AvailableErrataFilterController',
    ['$scope', 'translate', 'Nutupane', 'Filter', 'Rule',
    function ($scope, translate, Nutupane, Filter, Rule) {

        var nutupane, filterByDate;

        $scope.nutupane = nutupane = new Nutupane(Filter, {
                filterId: $scope.$stateParams.filterId,
                'sort_order': 'DESC',
                'sort_by': 'issued'
            },
            'availableErrata'
        );
        nutupane.enableSelectAllResults();

        filterByDate = function (date, type) {
            date = date.toISOString().split('T')[0];
            nutupane.addParam(type, date);
            nutupane.refresh();
        };

        $scope.detailsTable = nutupane.table;

        $scope.addErrata = function (filter) {
            var errataIds,
                rule,
                results = nutupane.getAllSelectedResults('errata_id');

            if (nutupane.table.allResultsSelected) {
                rule = new Rule({'errata_ids': results});
            } else {
                errataIds = results.included.ids;
                rule = new Rule({'errata_ids': errataIds});
            }

            nutupane.table.working = true;
            saveRule(rule, filter);
        };

        $scope.updateTypes = function (errataTypes) {
            var types = [];

            angular.forEach(errataTypes, function (value, key) {
                if (value) {
                    types.push(key);
                }
            });

            nutupane.addParam('types[]', types);
            nutupane.refresh();
        };

        $scope.$watch('rule.start_date', function (start) {
            if (start) {
                filterByDate(start, 'start_date');
            }
        });

        $scope.$watch('rule.end_date', function (end) {
            if (end) {
                filterByDate(end, 'end_date');
            }
        });

        function saveRule(rule, filter) {
            var params = {filterId: filter.id};

            return rule.$save(params, success, failure);
        }

        function success() {
            $scope.$parent.successMessages = [translate('Errata successfully added.')];
            nutupane.table.selectAllResults(false);
            nutupane.refresh();
        }

        function failure(response) {
            $scope.$parent.errorMessages = [response.data.displayMessage];
        }

    }]
);
