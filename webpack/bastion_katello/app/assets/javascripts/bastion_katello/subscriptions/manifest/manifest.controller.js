/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:ManifestController
 *
 * @requires $scope
 * @requires translate
 * @requires ManifestHistoryService
 *
 * @description
 *   Controls the managment of manifests for use by sub-controllers.
 */
angular.module('Bastion.subscriptions').controller('ManifestController',
    ['$scope', function ($scope) {
        $scope.panel = {loading: true};
    }]
);
