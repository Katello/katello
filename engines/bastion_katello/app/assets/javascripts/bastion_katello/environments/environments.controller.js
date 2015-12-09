/**
 * @ngdoc object
 * @name  Bastion.environments.controller:EnvironmentsController
 *
 * @requires $scope
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the environments path page.
 */
angular.module('Bastion.environments').controller('EnvironmentsController',
    ['$scope', 'PathsService',
        function ($scope, PathsService) {
            $scope.loading = true;

            PathsService.getActualPaths().then(function (data) {
                $scope.library = data.library;
                $scope.paths = data.paths;
                $scope.loading = false;
            });

            $scope.lastEnvironment = function (path) {
                return path.environments[path.environments.length - 1];
            };

        }]
);
