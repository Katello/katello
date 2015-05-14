/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewAvailableDockerRepositoriesController
 *
 * @requires $scope
 * @requires Repository
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentViewRepositoriesUtil
 *
 * @description
 *    Provides UI functionality add docker repositories to a content view
 */
angular.module('Bastion.content-views').controller('ContentViewAvailableDockerRepositoriesController',
    ['$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil',
    function ($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {

        var nutupane;

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'library': true,
            'content_type': 'docker'
        },
        'queryUnpaged');

        nutupane.searchTransform = function () {
            return "NOT ( content_view_ids:" + $scope.$stateParams.contentViewId + " )";
        };

        $scope.repositoriesTable = nutupane.table;

        $scope.addRepositories = function (contentView) {
            $scope.addSelectedRepositoriesToContentView(nutupane, contentView);
        };
    }]
);
