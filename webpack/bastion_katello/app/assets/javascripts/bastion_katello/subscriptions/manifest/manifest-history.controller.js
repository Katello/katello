/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:ManifestHistoryController
 *
 * @requires $scope
 *
 * @description
 *   Controls the import of a manifest.
 */
angular.module('Bastion.subscriptions').controller('ManifestHistoryController',
    ['$scope', 'Subscription', function ($scope, Subscription) {
        $scope.histories = Subscription.manifestHistory();
        $scope.histories.$promise.then(function (result) {
            $scope.statuses = result;
            $scope.panel.loading = false;
        });
    }]
);
