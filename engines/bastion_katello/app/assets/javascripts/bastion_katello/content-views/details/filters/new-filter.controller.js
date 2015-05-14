/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:NewFilterController
 *
 * @requires $scope
 * @requires Filter
 * @requires Rule
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewFilterController',
    ['$scope', 'Filter', 'Rule', function ($scope, Filter, Rule) {
        var filterType;

        function transitionToDetails(filter) {
            var state = '';

            if (filterType === 'erratumId') {
                state = 'content-views.details.filters.details.erratum.available';
            } else if (filterType === 'erratumDateType') {
                state = 'content-views.details.filters.details.erratum.dateType';
            } else if (filterType === 'rpm') {
                state = 'content-views.details.filters.details.rpm.details';
            } else if (filterType === 'package_group') {
                state = 'content-views.details.filters.details.package_group.available';
            }

            $scope.$emit('filter.created');
            $scope.transitionTo(state, {filterId: filter.id, contentViewId: filter['content_view'].id});
        }

        function addErrataDateTypeRule(filter) {
            var rule = new Rule({
                    types: ['security', 'enhancement', 'bugfix']
                }),
                addSuccess, error;

            addSuccess = function () {
                transitionToDetails(filter);
            };

            error = function (response) {
                $scope.errorMessages = [response.data.displayMessage];
            };

            rule.$save({filterId: filter.id}, addSuccess, error);
        }

        function success(filter) {
            if (filterType === 'erratumDateType') {
                addErrataDateTypeRule(filter);
            } else {
                transitionToDetails(filter);
            }
        }

        function failure(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.filterForm[field].$setValidity('server', false);
                $scope.filterForm[field].$error.messages = errors;
            });
        }

        $scope.filter = new Filter();
        $scope.working = false;

        $scope.save = function (filter, contentView) {
            filterType = filter.type;

            if (filter.type === 'erratumId' || filter.type === 'erratumDateType') {
                filter.type = 'erratum';
            }

            filter.$save({'content_view_id': contentView.id}, success, failure);
        };

    }]
);
