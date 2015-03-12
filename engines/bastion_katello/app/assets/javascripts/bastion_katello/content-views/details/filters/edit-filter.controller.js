/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

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
