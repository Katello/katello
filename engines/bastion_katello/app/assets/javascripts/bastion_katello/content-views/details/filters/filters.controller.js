/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FiltersController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Handles loading all filters for a content view.
 */
angular.module('Bastion.content-views').controller('FiltersController',
    ['$scope', 'translate', 'Filter', 'Nutupane', 'Notification', function ($scope, translate, Filter, Nutupane, Notification) {
        var nutupane, filterTypes;

        function removeFilter(id) {
            var success, failure;

            success = function () {
                nutupane.removeRow(id);
                Notification.setSuccessMessage(translate('Filters successfully removed.'));
            };

            failure = function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
            };

            Filter.delete({filterId: id}, success, failure);
        }

        if ($scope.stateIncludes('content-view.yum')) {
            filterTypes = ['rpm', 'package_group', 'erratum', 'modulemd'];
        } else {
            filterTypes = ['docker'];
        }
        nutupane = new Nutupane(Filter, {
            'content_view_id': $scope.$stateParams.contentViewId,
            'types[]': filterTypes
        });

        $scope.table = nutupane.table;

        $scope.$on('filter.created', function () {
            nutupane.refresh();
        });

        $scope.$on('filter.updated', function () {
            nutupane.refresh();
        });

        $scope.removeFilters = function () {
            var filterIds = nutupane.getAllSelectedResults().included.ids;

            angular.forEach(filterIds, removeFilter);
        };

        nutupane.table.closeItem = function () {};

        $scope.getFilterState = function (filter) {
            var state;

            switch (filter.type) {
            case "erratum":
                state = "content-view.yum.filter.erratum.list({filterId: filter.id})";
                if (filter.rules[0].types) {
                    state = "content-view.yum.filter.erratum.dateType({filterId: filter.id})";
                }
                break;
            case "rpm":
                state = "content-view.yum.filter.rpm({filterId: filter.id})";
                break;
            case "modulemd":
                state = "content-view.yum.filter.module-stream.list({filterId: filter.id})";
                break;
            case "package_group":
                state = "content-view.yum.filter.package_group.list({filterId: filter.id})";
                break;
            }

            return state;
        };
    }]
);
