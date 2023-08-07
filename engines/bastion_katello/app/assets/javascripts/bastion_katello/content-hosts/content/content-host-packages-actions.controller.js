/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesActionsController
 *
 * @requires $scope
 * @requires $location
 * @requires BastionConfig
 *
 * @description
 *   Provides the functionality for the content host package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesActionsController',
    ['$scope', '$location', 'BastionConfig', function ($scope, $location, BastionConfig) {
        var packageName = $location.search().package_name;
        $scope.remoteExecutionPresent = BastionConfig.remoteExecutionPresent;
        $scope.hostToolingEnabled = BastionConfig.hostToolingEnabled;

        $scope.packageAction = {actionType: 'packageInstall'}; //default to packageInstall

        if (packageName) {
            $scope.packageAction.term = packageName;
        }
    }
]);
