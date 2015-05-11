/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FiltersController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires Nutupane
 *
 * @description
 *   Handles loading all filters for a content view.
 */
angular.module('Bastion.content-views').controller('FiltersController',
    ['$scope', 'translate', 'Filter', 'Nutupane', function ($scope, translate, Filter, Nutupane) {
        var nutupane;

        function removeFilter(id) {
            var success, failure;

            success = function () {
                nutupane.removeRow(id);
                $scope.successMessages = [translate('Filters successfully removed.')];
            };

            failure = function (response) {
                $scope.errorMessages = [response.data.displayMessage];
            };

            Filter.delete({filterId: id}, success, failure);
        }

        nutupane = new Nutupane(Filter, {
            'content_view_id': $scope.$stateParams.contentViewId
        });

        $scope.detailsTable = nutupane.table;

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
                state = "content-views.details.filters.details.erratum.list({filterId: filter.id})";
                if (filter.rules[0].types) {
                    state = "content-views.details.filters.details.erratum.dateType({filterId: filter.id})";
                }
                break;
            case "rpm":
                state = "content-views.details.filters.details.rpm({filterId: filter.id})";
                break;
            case "package_group":
                state = "content-views.details.filters.details.package_group.list({filterId: filter.id})";
                break;
            }

            return state;
        };

    }]
);
