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
 * @name  Bastion.content-views.controller:PackageFilterListController
 *
 * @requires $scope
 * @requires gettext
 * @requires Filter
 * @requires Rule
 * @requires Nutupane
 *
 * @description
 *   Handles loading package groups that have been added to the filter via filter rules
 *   and provides a method to remove them.
 */
angular.module('Bastion.content-views').controller('PackageGroupFilterListController',
    ['$scope', 'gettext', 'Filter', 'Rule', 'Nutupane',
    function ($scope, gettext, Filter, Rule, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(
            Filter,
            {filterId: $scope.$stateParams.filterId},
            'packageGroups'
        );

        $scope.detailsTable = nutupane.table;

        $scope.removePackageGroups = function () {
            var packageGroupNames = nutupane.getAllSelectedResults('name').included.ids,
                rules;

            rules = findRules(packageGroupNames);

            angular.forEach(rules, function (rule) {
                rule.$delete(success, failure);
            });
        };

        function success(rule) {
            nutupane.removeRow(rule.name, 'name');
            $scope.successMessages = [gettext('Package Group successfully removed.')];
        }

        function failure(response) {
            $scope.errorMessages = [response.data.displayMessage];
        }

        function findRules(packageGroupNames) {
            var rules = [];

            angular.forEach(packageGroupNames, function (id) {
                var found;

                found = _.find($scope.filter.rules, function (rule) {
                    return (rule.name === id);
                });

                if (found) {
                    rules.push(new Rule(found));
                }
            });

            return rules;
        }

    }]
);
