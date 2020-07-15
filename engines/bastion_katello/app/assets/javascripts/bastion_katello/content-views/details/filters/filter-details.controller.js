/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Notification
 * @requires Filter
 *
 * @description
 *   Handles fetching a filter.
 */
angular.module('Bastion.content-views').controller('FilterDetailsController',
    ['$scope', '$q', 'translate', 'Notification', 'Filter', function ($scope, $q, translate, Notification, Filter) {
        $scope.filter = Filter.get({'content_view_id': $scope.$stateParams.contentViewId, filterId: $scope.$stateParams.filterId});

        $scope.updateFilter = function (filter) {
            var deferred = $q.defer();

            filter.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('Filter Updated - ' + $scope.filter.name));
            }, function (response) {
                deferred.reject(response);
                angular.forEach(response.data.errors, function (errorMessage) {
                    Notification.setErrorMessage(translate("An error occurred saving the Filter: ") + errorMessage);
                });
            });

            return deferred.promise;
        };
    }]
);
