/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesActionsController
 *
 * @requires $scope
 * @requires $location
 *
 * @description
 *   Provides the functionality for the content host package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesActionsController',
    ['$scope', '$location', function ($scope, $location) {
        var packageName = $location.search().package_name;

        $scope.packageAction = {actionType: 'packageInstall'}; //default to packageInstall

        if (packageName) {
            $scope.packageAction.term = packageName;
        }
    }
]);
