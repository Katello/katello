/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FiltersController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Nutupane
 * @requires GlobalNotification
 *
 * @description
 *   Handles loading all filters for a content view.
 */
angular.module('Bastion.content-views').controller('FiltersController',
    ['$scope', 'translate', 'Filter', 'Nutupane', 'GlobalNotification', function ($scope, translate, Filter, Nutupane, GlobalNotification) {
        var nutupane;

        function removeFilter(id) {
            var success, failure;

            success = function () {
                nutupane.removeRow(id);
                GlobalNotification.setSuccessMessage(translate('Filters successfully removed.'));
            };

            failure = function (response) {
                GlobalNotification.setErrorMessage(response.data.displayMessage);
            };

            Filter.delete({filterId: id}, success, failure);
        }

        nutupane = new Nutupane(Filter, {
            'content_view_id': $scope.$stateParams.contentViewId,
            'types[]': ["rpm", "package_group", "erratum"]
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
                state = "content-view.filter.erratum.list({filterId: filter.id})";
                if (filter.rules[0].types) {
                    state = "content-view.filter.erratum.dateType({filterId: filter.id})";
                }
                break;
            case "rpm":
                state = "content-view.filter.rpm({filterId: filter.id})";
                break;
            case "package_group":
                state = "content-view.filter.package_group.list({filterId: filter.id})";
                break;
            }

            return state;
        };

    }]
);
