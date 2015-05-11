/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterEditController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 *
 * @description
 *   Provides functionality for editing name and description of content view filters.
 */
angular.module('Bastion.content-views').controller('FilterEditController',
    ['$scope', '$q', 'translate', function ($scope, $q, translate) {
    $scope.successMessages = [];
    $scope.errorMessages = [];

    $scope.save = function (filter) {
        var deferred = $q.defer();
        var success;
        var failure = function (response) {
            deferred.reject(response);
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages.push(translate("An error occurred saving the Filter: ") + errorMessage);
            });
            $scope.working = false;
        };

        success = function (response) {
            deferred.resolve(response);
            $scope.successMessages.push(translate('Filter Saved'));
            $scope.working = false;
            $scope.$emit('filter.updated');
        };

        filter.$update(success, failure);
        return deferred.promise;
    };
}]);
