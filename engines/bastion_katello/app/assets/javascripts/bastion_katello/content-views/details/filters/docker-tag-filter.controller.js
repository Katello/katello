/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:DockerTagFilterController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Filter
 * @requires Rule
 * @requires DockerTag
 * @requires Notification
 *
 * @description
 *   Handles docker tag filter rules for a content view.
 */
angular.module('Bastion.content-views').controller('DockerTagFilterController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Filter', 'Rule', 'DockerTag', 'Notification', function ($scope, $location, translate, Nutupane, CurrentOrganization, Filter, Rule, DockerTag, Notification) {
        var nutupane, params;

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
        }

        function createRule(rule) {
            var success;

            success = function (result) {
                rule.id = result.id;
                rule.editMode = false;
                rule.working = false;

                Notification.setSuccessMessage(translate('Package successfully added.'));
            };

            if ($scope.valid(rule)) {
                Rule.save({filterId: $scope.filter.id}, rule, success, failure);
            }
        }

        function updateRule(rule) {
            var updateParams = {filterId: $scope.filter.id, ruleId: rule.id},
                success, error;

            // Need access to the original rule
            success = function () {
                rule.previous = {};
                rule.editMode = false;
                rule.working = false;
                Notification.setSuccessMessage(translate('Filter rule successfully updated.'));
            };

            error = function () {
                rule.working = false;
            };

            Rule.update(updateParams, rule, success, error);
        }

        function removeRule(rule) {
            var success, ruleId = rule.id;

            success = function () {
                nutupane.removeRow(ruleId);
                Notification.setSuccessMessage(translate('Filter rule successfully removed.'));
            };

            Rule.delete({filterId: $scope.$stateParams.filterId, ruleId: ruleId}, success, failure);
        }

        params = {
            filterId: $scope.$stateParams.filterId,
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        nutupane = new Nutupane(Filter, params, 'rules');
        $scope.table = nutupane.table;

        $scope.addRule = function () {
            var rule = new Rule();
            rule.editMode = true;
            $scope.table.addRow(rule);
        };

        $scope.saveRule = function (rule) {
            if (rule.id) {
                updateRule(rule);
            } else {
                createRule(rule);
            }
        };

        $scope.valid = function (rule) {
            return rule.name ? true : false;
        };

        $scope.backupPrevious = function (rule) {
            rule.previous = {};
            angular.copy(rule, rule.previous);
        };

        $scope.restorePrevious = function (rule) {
            if (rule.id) {
                angular.copy(rule.previous, rule);
            } else {
                $scope.table.rows.shift();
            }
            rule.previous = {};
        };

        $scope.removeRules = function () {
            angular.forEach($scope.table.getSelected(), function (rule) {
                removeRule(rule);
            });
        };

        $scope.fetchAutocompleteName = function (term) {
            var repositoryIds = $scope.contentView['repository_ids'],
                promise;

            promise = DockerTag.autocompleteName({'repoids[]': repositoryIds, term: term}).$promise;

            return promise.then(function (data) {
                return data.results;
            });
        };

        $scope.filterRepositoriesByType = function () {
            return (_.filter($scope.filter.repositories, ["content_type", "docker"]));
        };
    }]
);
