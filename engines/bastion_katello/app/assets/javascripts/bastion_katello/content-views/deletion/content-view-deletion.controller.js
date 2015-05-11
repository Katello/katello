/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewDeletionController
 *
 * @requires $scope
 * @requires ContentView
 *
 * @description
 *   Provides the functionality for deleting Content Views
 */
angular.module('Bastion.content-views').controller('ContentViewDeletionController',
    ['$scope', 'ContentView', function ($scope, ContentView) {

        function success() {
            $scope.removeRow($scope.contentView.id);
            $scope.transitionTo('content-views.index');
            $scope.working = false;
        }

        function failure(response) {
            $scope.$parent.errorMessages = [response.data.displayMessage];
            $scope.working = false;
        }

        if (angular.isUndefined($scope.versions)) {
            $scope.reloadVersions();
        }

        $scope.delete = function () {
            $scope.working = true;
            ContentView.remove({id: $scope.contentView.id}, success, failure);
        };

        $scope.conflictingVersions = function () {
            return _.reject($scope.versions, function (version) {
                return version.environments.length === 0;
            });
        };

        $scope.environmentNames = function (version) {
            return _.pluck($scope.readableEnvironments(version), 'name');
        };

        $scope.readableEnvironments = function (version) {
            return _.reject(version.environments, function (env) {
                return !env.permissions.readable;
            });
        };

    }]
);
