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
    ['$scope', 'Organization', 'CurrentOrganization',
        function ($scope, Organization, CurrentOrganization) {

            Organization.paths({id: CurrentOrganization}, function (paths) {
                var actualPaths = [];

                $scope.library = paths[0].environments[0];

                angular.forEach(paths, function (path, index) {
                    paths[index].environments.splice(0, 1);

                    if (paths[index].environments.length !== 0) {
                        actualPaths.push(path);
                    }
                });

                $scope.paths = actualPaths;
            });

            $scope.lastEnvironment = function (path) {
                return path.environments[path.environments.length - 1];
            };

        }]
);
