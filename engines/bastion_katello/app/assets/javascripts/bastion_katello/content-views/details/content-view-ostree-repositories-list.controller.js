(function () {

    /**
     * @ngdoc object
     * @name  Bastion.content-views.controller:ContentViewOstreeRepositoriesListController
     *
     * @requires $scope
     * @requires Repository
     * @requires Nutupane
     * @requires CurrentOrganization
     * @requires ContentViewRepositoriesUtil
     *
     * @description
     *    Provides UI functionality list/remove ostree repositories from a content view
     */
    function ContentViewOstreeRepositoriesListController($scope, Repository, Nutupane, CurrentOrganization, ContentViewRepositoriesUtil) {
        var nutupane, nutupaneParams = {
            'disableAutoLoad': true
        };

        ContentViewRepositoriesUtil($scope);

        nutupane = new Nutupane(Repository, {
            'organization_id': CurrentOrganization,
            'content_view_id': $scope.$stateParams.contentViewId,
            'content_type': 'ostree'
        },
        'queryPaged', nutupaneParams);
        $scope.controllerName = 'katello_repositories';

        nutupane.masterOnly = true;
        nutupane.load();

        $scope.table = nutupane.table;

        $scope.removeRepositories = function () {
            $scope.removeSelectedRepositoriesFromContentView(nutupane, $scope.contentView);
        };
    }

    angular
        .module('Bastion.content-views')
        .controller('ContentViewOstreeRepositoriesListController', ContentViewOstreeRepositoriesListController);

    ContentViewOstreeRepositoriesListController.$inject = [
        '$scope', 'Repository', 'Nutupane', 'CurrentOrganization', 'ContentViewRepositoriesUtil'
    ];

})();
