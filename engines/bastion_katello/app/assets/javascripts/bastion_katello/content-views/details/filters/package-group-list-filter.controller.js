/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:PackageFilterListController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Rule
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Handles loading package groups that have been added to the filter via filter rules
 *   and provides a method to remove them.
 */
angular.module('Bastion.content-views').controller('PackageGroupFilterListController',
    ['$scope', 'translate', 'PackageGroup', 'Rule', 'Nutupane', 'Notification',
    function ($scope, translate, PackageGroup, Rule, Nutupane, Notification) {
        var nutupane;

        function success(rule) {
            nutupane.removeRow(rule.uuid, 'uuid');
            $scope.filter.rules = _.reject($scope.filter.rules, function (filterRule) {
                return rule.id === filterRule.id;
            });
            Notification.setSuccessMessage(translate('Package Group successfully removed.'));
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
        }

        function findRules(packageGroupIds) {
            var rules = [];

            angular.forEach(packageGroupIds, function (id) {
                var found;

                found = _.find($scope.filter.rules, function (rule) {
                    return (rule.uuid === id);
                });

                if (found) {
                    rules.push(new Rule(found));
                }
            });

            return rules;
        }

        nutupane = new Nutupane(PackageGroup, {
            filterId: $scope.$stateParams.filterId,
            'sort_order': 'ASC',
            'sort_by': 'name'
            },
            'queryUnpaged'
        );
        $scope.controllerName = 'katello_package_groups';

        $scope.table = nutupane.table;
        nutupane.table.closeItem = function () {};

        $scope.removePackageGroups = function () {
            var packageGroupIds = nutupane.getAllSelectedResults('uuid').included.ids,
                rules;

            rules = findRules(packageGroupIds);

            angular.forEach(rules, function (rule) {
                rule.$delete(success, failure);
            });
        };

    }]
);
