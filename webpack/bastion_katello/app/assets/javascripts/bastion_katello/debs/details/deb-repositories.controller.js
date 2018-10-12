(function () {

    /**
     * @ngdoc object
     * @name  Bastion.debs.controller:DebRepositoriesController
     *
     * @description
     *   Provides the functionality for the debs details repositories page.
     */
    function DebRepositoriesController($scope, Nutupane, Repository, CurrentOrganization) {
        var repositoriesNutupane,
            params = {
                'deb_id': $scope.$stateParams.debId,
                'organization_id': CurrentOrganization
            };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.controllerName = 'katello_repositories';
        repositoriesNutupane.masterOnly = true;
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
        'CurrentOrganization'
    ];

})();
