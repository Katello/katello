/**
 * @ngdoc object
 * @name  Bastion.ostree-branches.controller:OstreeBranchController
 *
 * @requires $scope
 * @requires OstreeBranch
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the Ostree Branch action pane.
 */
angular.module('Bastion.ostree-branches').controller('OstreeBranchController', ['$scope', 'OstreeBranch', 'ApiErrorHandler',
    function ($scope, OstreeBranch, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.branch) {
            $scope.panel.loading = false;
        }

        $scope.branch = OstreeBranch.get({id: $scope.$stateParams.branchId}, function (branch) {
            $scope.$broadcast('branch.loaded', branch);
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }
]);
