(function () {

    /**
     * @ngdoc object
     * @name  Bastion.content-views.controller:ContentViewAvailableDebRepositoriesController
     *
     * @requires $scope
     * @requires Repository
     * @requires Nutupane
     * @requires CurrentOrganization
     * @requires ContentViewRepositoriesUtil
     *
     * @description
     *    Provides UI functionality add deb repositories to a content view
     */
    function ContentViewAvailableDebRepositoriesController($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {
        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'library': true,
            'content_type': 'deb',
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
        .controller('ContentViewAvailableDebRepositoriesController', ContentViewAvailableDebRepositoriesController);

    ContentViewAvailableDebRepositoriesController.$inject = [
        '$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil'
    ];

})();
