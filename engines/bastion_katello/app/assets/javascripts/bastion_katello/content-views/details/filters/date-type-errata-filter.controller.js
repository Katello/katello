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

        function success() {
            $scope.successMessages = [translate('Updated errata filter - ' + $scope.filter.name)];
        }

        function failure(response) {
            $scope.rule.working = false;
            $scope.errorMessages = [response.data.displayMessage];
        }

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

            if (angular.isUndefined($scope.rule['date_type'])) {
                $scope.rule['date_type'] = "updated";
            }
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

    }]
);
