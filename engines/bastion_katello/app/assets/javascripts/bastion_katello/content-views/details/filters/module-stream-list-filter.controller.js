/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:PackageFilterListController
 *
 * @requires $scope
 * @requires translate
 * @requires ModuleStream
 * @requires Rule
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Handles loading module streams that have been added to the filter via filter rules
 *   and provides a method to remove them.
 */
angular.module('Bastion.content-views').controller('ModuleStreamFilterListController',
    ['$scope', 'translate', 'ModuleStream', 'Rule', 'Nutupane', 'Notification',
    function ($scope, translate, ModuleStream, Rule, Nutupane, Notification) {
        var nutupane;

        function success(rule) {
            nutupane.removeRow(rule['module_stream_id'], 'id');
            $scope.filter.rules = _.reject($scope.filter.rules, function (filterRule) {
                return rule.id === filterRule.id;
            });
            Notification.setSuccessMessage(translate('Module Stream successfully removed.'));
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
        }

        function findRules(moduleStreamIds) {
            var rules = [];

            angular.forEach(moduleStreamIds, function (id) {
                var found;

                found = _.find($scope.filter.rules, function (rule) {
                    return (rule['module_stream_id'] === id);
                });

                if (found) {
                    rules.push(new Rule(found));
                }
            });

            return rules;
        }

        nutupane = new Nutupane(ModuleStream, {
            filterId: $scope.$stateParams.filterId,
            'sort_order': 'ASC',
            'sort_by': 'name'
            },
            'queryPaged'
        );

        $scope.table = nutupane.table;
        nutupane.table.closeItem = function () {};

        $scope.removeModuleStreams = function () {
            var moduleStreamIds = nutupane.getAllSelectedResults().included.ids,
                rules;

            rules = findRules(moduleStreamIds);

            angular.forEach(rules, function (rule) {
                rule.$delete(success, failure);
            });
        };
    }]
);
