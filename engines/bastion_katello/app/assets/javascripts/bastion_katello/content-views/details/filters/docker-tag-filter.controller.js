/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:DockerTagFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires Rule
 * @requires DockerTag
 * @requires GlobalNotification
 *
 * @description
 *   Handles docker tag filter rules for a content view.
 */
angular.module('Bastion.content-views').controller('DockerTagFilterController',
    ['$scope', 'translate', 'Rule', 'DockerTag', 'GlobalNotification', function ($scope, translate, Rule, DockerTag, GlobalNotification) {

        function failure(response) {
            GlobalNotification.setErrorMessage(response.data.displayMessage);
        }

        function removeRule(rule) {
            var success,
                rulesCopy = angular.copy($scope.filter.rules),
                ruleId = rule.id;

            success = function () {
                angular.forEach(rulesCopy, function (ruleCopy, index) {
                    if (ruleCopy.id === ruleId) {
                        $scope.filter.rules.splice(index, 1);
                    }
                });
                GlobalNotification.setSuccessMessage(translate('Filter rule successfully removed.'));
            };

            Rule.delete({filterId: rule['content_view_filter_id'], ruleId: ruleId}, success, failure);
        }

        function addSuccess(rule) {
            $scope.rule = {};
            $scope.rule.editMode = false;
            $scope.rule.working = false;
            $scope.filter.rules.push(rule);

            GlobalNotification.setSuccessMessage(translate('Filter rule successfully added.'));
        }

        $scope.rule = {
            editMode: false,
            working: false
        };

        $scope.filter.$promise.then(function (filter) {
            $scope.table = {rows: filter.rules};
        });

        $scope.addRule = function (rule, filter) {
            if ($scope.valid(rule)) {
                Rule.save({filterId: filter.id}, rule, addSuccess, failure);
            }
        };

        $scope.updateRule = function (rule, filter) {
            var params = {filterId: filter.id, ruleId: rule.id},
                success, error;

            // Need access to the original rule
            success = function () {
                rule.previous = {};
                rule.editMode = false;
                rule.working = false;
                GlobalNotification.setSuccessMessage(translate('Filter rule successfully updated.'));
            };

            error = function () {
                rule.working = false;
            };

            Rule.update(params, rule, success, error);
        };

        $scope.valid = function (rule) {
            return rule.name ? true : false;
        };

        $scope.backupPrevious = function (rule) {
            rule.previous = {};
            angular.copy(rule, rule.previous);
        };

        $scope.restorePrevious = function (rule) {
            angular.copy(rule.previous, rule);
            rule.previous = {};
        };

        $scope.getSelectedRules = function (filter) {
            var rules = [];
            angular.forEach(filter.rules, function (rule) {
                if (rule.selected) {
                    rules.push(rule);
                }
            });
            return rules;
        };

        $scope.removeRules = function (filter) {
            angular.forEach($scope.getSelectedRules(filter), function (rule) {
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
