/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:AvailableModuleStreamFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires ModuleStream
 * @requires Rule
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Handles fetching module streams that are available to add to a filter and saving
 *   each selected module stream as a filter rule.
 */
angular.module('Bastion.content-views').controller('AvailableModuleStreamFilterController',
    ['$scope', 'translate', 'ModuleStream', 'Rule', 'Nutupane', 'Notification',
    function ($scope, translate, ModuleStream, Rule, Nutupane, Notification) {
        var nutupane;

        $scope.nutupane = nutupane = new Nutupane(
            ModuleStream,
            {
              filterId: $scope.$stateParams.filterId,
              'available_for': 'content_view_filter',
              'sort_order': 'ASC',
              'sort_by': 'name'
            },
            'queryPaged'
        );

        function success(data) {
            var rules;

            if (data.results) {
                rules = data.results;
            } else {
                rules = [data];
            }

            $scope.filter.rules = _.union($scope.filter.rules, rules);
            Notification.setSuccessMessage(translate('Module Stream successfully added.'));
            nutupane.table.selectAllResults(false);
            nutupane.refresh();
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
        }

        $scope.table = nutupane.table;
        nutupane.table.closeItem = function () {};

        function saveRules(rules, filter) {
            var params = {filterId: filter.id};

            return rules.$save(params, success, failure);
        }

        $scope.addModuleStreams = function (filter) {
            var moduleStreams = nutupane.getAllSelectedResults().included.ids,
                rules;
            rules = new Rule({"module_stream_ids": moduleStreams});
            nutupane.table.working = true;
            saveRules(rules, filter);
        };
    }]
);
