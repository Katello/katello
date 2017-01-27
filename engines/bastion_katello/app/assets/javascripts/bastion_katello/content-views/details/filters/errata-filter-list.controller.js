/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ErrataFilterListController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires Filter
 * @requires Rule
 * @requires Notification
 *
 * @description
 *   Handles displaying a list of errata currently added to the filter and the ability
 *   to remove errata from the filter.
 */
angular.module('Bastion.content-views').controller('ErrataFilterListController',
    ['$scope', 'translate', 'Nutupane', 'Erratum', 'Rule', 'Notification',
    function ($scope, translate, Nutupane, Erratum, Rule, Notification) {
        var nutupane;

        function findRules(errataIds) {
            var rules = [];

            angular.forEach(errataIds, function (id) {
                var found;

                found = _.find($scope.filter.rules, function (rule) {
                    return (rule['errata_id'] === id);
                });

                if (found) {
                    rules.push(new Rule(found));
                }
            });

            return rules;
        }

        function success(rule) {
            nutupane.removeRow(rule['errata_id'], 'errata_id');
            $scope.filter.rules = _.reject($scope.filter.rules, function (filterRule) {
                return rule.id === filterRule.id;
            });
            Notification.setSuccessMessage(translate('Errata successfully removed.'));
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
        }

        $scope.nutupane = nutupane = new Nutupane(Erratum, {
                filterId: $scope.$stateParams.filterId,
                'sort_order': 'DESC',
                'sort_by': 'issued'
            },
            'queryUnpaged'
        );
        $scope.controllerName = 'katello_errata';

        $scope.table = nutupane.table;

        $scope.removeErrata = function () {
            var errataIds = nutupane.getAllSelectedResults('errata_id').included.ids,
                rules;

            rules = findRules(errataIds);

            angular.forEach(rules, function (rule) {
                rule.$delete(success, failure);
            });
        };

        $scope.errataFilter = function () {
            return true;
        };

    }]
);
