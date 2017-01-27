/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:AvailablePackageGroupFilterController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Rule
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Handles fetching package groups that are available to add to a filter and saving
 *   each selected package group as a filter rule.
 */
angular.module('Bastion.content-views').controller('AvailablePackageGroupFilterController',
    ['$scope', 'translate', 'PackageGroup', 'Rule', 'Nutupane', 'Notification',
    function ($scope, translate, PackageGroup, Rule, Nutupane, Notification) {
        var nutupane;

        nutupane = new Nutupane(
            PackageGroup,
            {
              filterId: $scope.$stateParams.filterId,
              'available_for': 'content_view_filter',
              'sort_order': 'ASC',
              'sort_by': 'name'

            },
            'queryUnpaged'
        );
        $scope.controllerName = 'katello_package_groups';

        function success(rule) {
            nutupane.removeRow(rule.uuid, 'uuid');
            $scope.filter.rules.push(rule);
            Notification.setSuccessMessage(translate('Package Group successfully added.'));
        }

        function failure(response) {
            angular.forEach(response.data.displayMessage, function (error) {
                Notification.setErrorMessage(error);
            });
        }

        function saveRule(rule, filter) {
            var params = {filterId: filter.id};

            rule.$save(params, success, failure);
        }

        $scope.table = nutupane.table;
        nutupane.masterOnly = true;
        nutupane.table.closeItem = function () {};

        $scope.addPackageGroups = function (filter) {
            var packageGroups = nutupane.getAllSelectedResults().included.resources;

            angular.forEach(packageGroups, function (group) {
                var rule = new Rule({uuid: group.uuid, name: group.name});
                saveRule(rule, filter);
            });
        };

    }]
);
