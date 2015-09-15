/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:PackageFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires Rule
 *
 * @description
 */
angular.module('Bastion.content-views').controller('PackageFilterController',
    ['$scope', 'translate', 'Rule', 'Package', function ($scope, translate, Rule, Package) {

        function type(rule) {
            var typeId;

            if (rule.version) {
                typeId = 'equal';
            } else if (rule['min_version'] && !rule['max_version']) {
                typeId = 'greater';
            } else if (!rule.min && rule['max_version']) {
                typeId = 'less';
            } else if (rule.min && rule['max_version']) {
                typeId = 'range';
            } else {
                typeId = 'all';
            }

            return typeId;
        }

        function failure(response) {
            $scope.errorMessages = [response.data.displayMessage];
        }

        function addType(rules) {
            angular.forEach(rules, function (rule) {
                rule.type = type(rule);
            });
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
                $scope.successMessages = [translate('Package successfully removed.')];
            };

            Rule.delete({filterId: rule['content_view_filter_id'], ruleId: ruleId}, success, failure);
        }

        function addSuccess(rule) {
            $scope.rule = {
                type: 'all'
            };
            $scope.rule.editMode = false;
            $scope.rule.working = false;
            addType([rule]);
            $scope.filter.rules.push(rule);

            $scope.successMessages = [translate('Package successfully added.')];
        }

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.rule = {
            type: 'all',
            editMode: false,
            working: false
        };

        $scope.filter.$promise.then(function (filter) {
            addType(filter.rules);
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
                $scope.successMessages = [translate('Package successfully updated.')];
            };

            error = function () {
                rule.working = false;
            };

            Rule.update(params, rule, success, error);
        };

        $scope.valid = function (rule) {
            var valid = rule.name ? true : false;

            if (rule.type === 'equal') {
                valid = valid && rule.version;
            } else if (rule.type === 'less') {
                valid = valid && rule['max_version'];
            } else if (rule.type === 'greater') {
                valid = valid && rule['min_version'];
            } else if (rule.type === 'range') {
                valid = valid && rule['min_version'] && rule['max_version'];
            }

            return valid;
        };

        $scope.clearValues = function (rule) {
            rule.version = undefined;
            rule['min_version'] = undefined;
            rule['max_version'] = undefined;
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

        $scope.fetchAutocomplete = function (term) {
            var repositoryIds = $scope.contentView['repository_ids'],
                promise;

            promise = Package.autocompleteName({repoids: repositoryIds, term: term}).$promise;

            return promise.then(function (data) {
                return data.results;
            });
        };

    }]
);
