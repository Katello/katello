(function () {

    /**
     * @ngdoc object
     * @name  Bastion.debs.controller:DebRepositoriesController
     *
     * @description
     *   Provides the functionality for the debs details repositories page.
     *
     * @requires translate
     *
     */
    function DebRepositoriesController($scope, Nutupane, Repository, CurrentOrganization, translate) {
        var repositoriesNutupane,
            params = {
                'deb_id': $scope.$stateParams.debId,
                'organization_id': CurrentOrganization
            };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.controllerName = 'katello_repositories';

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Repositories');

        repositoriesNutupane.primaryOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        $scope.table = repositoriesNutupane.table;
    }

    angular
        .module('Bastion.debs')
        .controller('DebRepositoriesController', DebRepositoriesController);

    DebRepositoriesController.$inject = [
        '$scope',
        'Nutupane',
        'Repository',
        'CurrentOrganization',
        'translate'
    ];

})();
