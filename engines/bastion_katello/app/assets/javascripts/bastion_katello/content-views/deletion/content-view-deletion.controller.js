/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewDeletionController
 *
 * @requires $scope
 * @requires ContentView
 * @requires Notification
 *
 * @description
 *   Provides the functionality for deleting Content Views
 */
angular.module('Bastion.content-views').controller('ContentViewDeletionController',
    ['$scope', 'ContentView', 'Notification', function ($scope, ContentView, Notification) {

        function success() {
            $scope.transitionTo('content-views');
            $scope.working = false;
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
            $scope.working = false;
        }

        $scope.delete = function () {
            $scope.working = true;
            ContentView.remove({id: $scope.contentView.id}, success, failure);
        };

        $scope.environmentNames = function (version) {
            return _.map($scope.readableEnvironments(version), 'name');
        };

        $scope.readableEnvironments = function (version) {
            return _.reject(version.environments, function (env) {
                return !env.permissions.readable;
            });
        };

        $scope.conflictingVersions = ContentView.conflictingVersions({id: $scope.$stateParams.contentViewId});
    }]
);
