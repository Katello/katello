/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewAvailableRepositoriesController
 *
 * @requires $scope
 * @requires Repository
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentViewRepositoriesUtil
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewAvailableRepositoriesController',
    ['$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil',
    function ($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {

        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'library': true,
            'content_type': 'yum',
            'content_view_id': $scope.$stateParams.contentViewId,
            'available_for': 'content_view'
        },
        'queryPaged', nutupaneParams);
        $scope.controllerName = 'katello_repositories';

        nutupane.load();

        $scope.table = nutupane.table;

        $scope.addRepositories = function (contentView) {
            $scope.addSelectedRepositoriesToContentView(nutupane, contentView);
        };

    }]
);
