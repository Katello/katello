/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsActionsController
 *
 * @requires $scope
 *
 * @description
 *   Provides the functionality for the content host deb package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsActionsController',
    ['$scope', function ($scope) {
        $scope.packageAction = {actionType: 'packageInstall'};  // default to packageInstall
    }
]);
