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
 * @name  Bastion.content-views.controller:AvailablePackageGroupFilterController
 *
 * @requires $scope
 * @requires gettext
 * @requires Filter
 * @requires Rule
 * @requires Nutupane
 *
 * @description
 *   Handles fetching package groups that are available to add to a filter and saving
 *   each selected package group as a filter rule.
 */
angular.module('Bastion.content-views').controller('AvailablePackageGroupFilterController',
    ['$scope', 'gettext', 'Filter', 'Rule', 'Nutupane',
    function ($scope, gettext, Filter, Rule, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(
            Filter,
            {filterId: $scope.$stateParams.filterId},
            'availablePackageGroups'
        );

        $scope.detailsTable = nutupane.table;

        $scope.addPackageGroups = function (filter) {
            var packageGroupNames = nutupane.getAllSelectedResults('name').included.ids;

            angular.forEach(packageGroupNames, function (name) {
                var rule = new Rule({name: name});
                saveRule(rule, filter);
            });
        };

        function saveRule(rule, filter) {
            var params = {filterId: filter.id};

            rule.$save(params, success, failure);
        }

        function success(rule) {
            nutupane.removeRow(rule.name, 'name');
            $scope.successMessages = [gettext('Package Group successfully added.')];
        }

        function failure(response) {
            $scope.errorMessages = [response.data.displayMessage];
        }

    }]
);
