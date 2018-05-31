/**
 * @ngdoc object
 * @name  Bastion.environments.controller:EnvironmentsController
 *
 * @requires $scope
 * @requires PathsService
 * @requires $location
 * @requires Organization
 * @requires CurrentOrganization
 * @requires Nutupane
 * @requires Environment
 *
 * @description
 *   Provides the functionality for the environments path page.
 */
angular.module('Bastion.environments').controller('EnvironmentsController',
    ['$scope', 'PathsService', '$location', 'Organization', 'CurrentOrganization', 'Nutupane', 'Environment',
        function ($scope, PathsService, $location, Organization, CurrentOrganization, Nutupane, Environment) {

            var params = {
                'organization_id': CurrentOrganization,
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'paged': true
            };

            var nutupane = new Nutupane(Environment, params);
            $scope.table = nutupane.table;

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
