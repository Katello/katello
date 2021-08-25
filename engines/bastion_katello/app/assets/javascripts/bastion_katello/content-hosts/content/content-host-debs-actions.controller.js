/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsActionsController
 *
 * @requires $scope
 * @requires $location
 *
 * @description
 *   Provides the functionality for the content host deb package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsActionsController',
    ['$scope', '$location', function ($scope, $location) {
        var packageName = $location.search().package_name;
        $scope.packageAction = {actionType: 'packageInstall'};  // default to packageInstall

        if (packageName) {
            $scope.packageAction.term = packageName;
        }
    }
]);
