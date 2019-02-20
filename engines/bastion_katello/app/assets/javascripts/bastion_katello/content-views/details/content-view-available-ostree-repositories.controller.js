/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewAvailableOstreeRepositoriesController
 *
 * @requires $scope
 * @requires Repository
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentViewRepositoriesUtil
 *
 * @description
 *    Provides UI functionality add ostree repositories to a content view
 */
angular.module('Bastion.content-views').controller('ContentViewAvailableOstreeRepositoriesController',
    ['$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil',
    function ($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {

        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };
        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'library': true,
            'content_type': 'ostree',
            'content_view_id': $scope.$stateParams.contentViewId,
            'available_for': 'content_view'
        },
        'queryPaged', nutupaneParams);
        $scope.controllerName = 'katello_repositories';

        nutupane.masterOnly = true;
        nutupane.load();

        $scope.table = nutupane.table;

        $scope.addRepositories = function (contentView) {
            $scope.addSelectedRepositoriesToContentView(nutupane, contentView);
        };
    }]
);
