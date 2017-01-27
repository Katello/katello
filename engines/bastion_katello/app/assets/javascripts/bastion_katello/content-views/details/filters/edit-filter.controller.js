/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterEditController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Notification
 *
 * @description
 *   Provides functionality for editing name and description of content view filters.
 */
angular.module('Bastion.content-views').controller('FilterEditController',
    ['$scope', '$q', 'translate', 'Notification', function ($scope, $q, translate, Notification) {
    $scope.save = function (filter) {
        var deferred = $q.defer();
        var success;
        var failure = function (response) {
            deferred.reject(response);
            angular.forEach(response.data.errors, function (errorMessage) {
                Notification.setErrorMessage(translate("An error occurred saving the Filter: ") + errorMessage);
            });
            $scope.working = false;
        };

        success = function (response) {
            deferred.resolve(response);
            Notification.setSuccessMessage(translate('Filter Saved'));
            $scope.working = false;
            $scope.$emit('filter.updated');
        };

        filter.$update(success, failure);
        return deferred.promise;
    };
}]);
