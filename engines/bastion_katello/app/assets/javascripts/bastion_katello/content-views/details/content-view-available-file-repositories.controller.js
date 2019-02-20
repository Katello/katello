(function () {

    /**
     * @ngdoc object
     * @name  Bastion.content-views.controller:ContentViewAvailableFileRepositoriesController
     *
     * @requires $scope
     * @requires Repository
     * @requires Nutupane
     * @requires CurrentOrganization
     * @requires ContentViewRepositoriesUtil
     *
     * @description
     *    Provides UI functionality add file repositories to a content view
     */
    function ContentViewAvailableFileRepositoriesController($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {
        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'library': true,
            'content_type': 'file',
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
    }

    angular
        .module('Bastion.content-views')
        .controller('ContentViewAvailableFileRepositoriesController', ContentViewAvailableFileRepositoriesController);

    ContentViewAvailableFileRepositoriesController.$inject = [
        '$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil'
    ];

})();
