/**
 * @ngdoc object
 * @name  Bastion.ostree-branches.controller:OstreeBranchesDetailsController
 *
 * @requires $scope
 * @requires OstreeBranch
 *
 * @description
 *   Provides the functionality for the Ostree Branch action pane.
 */
angular.module('Bastion.ostree-branches').controller('OstreeBranchesDetailsController', ['$scope', 'OstreeBranch',
    function ($scope, OstreeBranch) {
        if ($scope.branch) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.branch = OstreeBranch.get({id: $scope.$stateParams.branchId}, function () {
            $scope.panel.loading = false;
        });
    }
]);
