/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagDetailsController
 *
 * @requires $scope
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the docker tags details action pane.
 */
angular.module('Bastion.docker-tags').controller('DockerTagDetailsController',
    ['$scope', '$location', 'DockerTag', 'CurrentOrganization', 'ApiErrorHandler',
    function ($scope, $location, DockerTag, CurrentOrganization, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.tag) {
            $scope.panel.loading = false;
        }

        $scope.tag = DockerTag.get({id: $scope.$stateParams.tagId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }
]);
