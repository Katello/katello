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
 * @name  Bastion.content-views.controller:DateTypeErrataFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires Rule
 *
 * @description
 *   Handles creating an errata filter that allows specification of a start date, end date and/or
 *   set of errata types by which to dynamically filter.
 */
angular.module('Bastion.content-views').controller('DateTypeErrataFilterController',
    ['$scope', 'translate', 'Rule', function ($scope, translate, Rule) {

        $scope.filter.$promise.then(function (filter) {
            $scope.types = {
                enhancement: false,
                bugfix: false,
                security: false
            };
            $scope.rule = new Rule(filter.rules[0]);

            angular.forEach($scope.types, function (value, type) {
                if ($scope.rule.types.indexOf(type) > -1) {
                    $scope.types[type] = true;
                }
            });
        });

        $scope.updateTypes = function (types) {
            $scope.rule.types = [];

            angular.forEach(types, function (chosen, type) {
                if (chosen) {
                    $scope.rule.types.push(type);
                }
            });
        };

        $scope.save = function (rule, filter) {
            var params = {filterId: filter.id, ruleId: rule.id};
            rule.$update(params, success, failure);
            $scope.filter.rules[0] = rule;
        };

        function success() {
            $scope.successMessages = [translate('Updated errata filter - ' + $scope.filter.name)];
        }

        function failure(response) {
            $scope.rule.working = false;
            $scope.errorMessages = [response.data.displayMessage];
        }

    }]
);
