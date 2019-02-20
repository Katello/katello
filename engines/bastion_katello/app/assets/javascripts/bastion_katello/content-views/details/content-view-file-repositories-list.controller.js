(function () {

    /**
     * @ngdoc object
     * @name  Bastion.content-views.controller:ContentViewFileRepositoriesListController
     *
     * @requires $scope
     * @requires Repository
     * @requires Nutupane
     * @requires CurrentOrganization
     * @requires ContentViewRepositoriesUtil
     *
     * @description
     *    Provides UI functionality list/remove file repositories from a content view
     */
    function ContentViewFileRepositoriesListController($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {
        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'content_view_id': $scope.$stateParams.contentViewId,
            'content_type': 'file'
        },
        'queryPaged', nutupaneParams);
        $scope.controllerName = 'katello_repositories';

        nutupane.load();

        $scope.table = nutupane.table;

        $scope.removeRepositories = function () {
            $scope.removeSelectedRepositoriesFromContentView(nutupane, $scope.contentView);
        };
    }

    angular
        .module('Bastion.content-views')
        .controller('ContentViewFileRepositoriesListController', ContentViewFileRepositoriesListController);

    ContentViewFileRepositoriesListController.$inject = [
        '$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil'
    ];

})();
