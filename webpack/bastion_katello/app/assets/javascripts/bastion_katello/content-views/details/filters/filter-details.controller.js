/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterDetailsController
 *
 * @requires $scope
 * @requires Filter
 *
 * @description
 *   Handles fetching a filter.
 */
angular.module('Bastion.content-views').controller('FilterDetailsController',
    ['$scope', 'Filter', function ($scope, Filter) {

        $scope.filter = Filter.get({'content_view_id': $scope.$stateParams.contentViewId, filterId: $scope.$stateParams.filterId});

        $scope.updateFilter = function (filter) {
            filter.$update();
        };

    }]
);
