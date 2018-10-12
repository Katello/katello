/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostPackagesActionsController
 *
 * @requires $scope
 *
 * @description
 *   Provides the functionality for the content host package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostPackagesActionsController',
    ['$scope', function ($scope) {
        $scope.packageAction = {actionType: 'packageInstall'}; //default to packageInstall
    }
]);
