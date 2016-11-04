/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterEditController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires GlobalNotification
 *
 * @description
 *   Provides functionality for editing name and description of content view filters.
 */
angular.module('Bastion.content-views').controller('FilterEditController',
    ['$scope', '$q', 'translate', 'GlobalNotification', function ($scope, $q, translate, GlobalNotification) {
    $scope.save = function (filter) {
        var deferred = $q.defer();
        var success;
        var failure = function (response) {
            deferred.reject(response);
            angular.forEach(response.data.errors, function (errorMessage) {
                GlobalNotification.setErrorMessage(translate("An error occurred saving the Filter: ") + errorMessage);
            });
            $scope.working = false;
        };

        success = function (response) {
            deferred.resolve(response);
            GlobalNotification.setSuccessMessage(translate('Filter Saved'));
            $scope.working = false;
            $scope.$emit('filter.updated');
        };

        filter.$update(success, failure);
        return deferred.promise;
    };
}]);
