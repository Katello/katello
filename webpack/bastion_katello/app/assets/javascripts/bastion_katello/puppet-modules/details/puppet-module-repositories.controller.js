(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModuleRepositoriesController
     *
     * @description
     *   Provides the functionality for the puppet modules details repositories page.
     */
    function PuppetModuleRepositoriesController($scope, Nutupane, Repository, CurrentOrganization) {
        var repositoriesNutupane,
            params = {
                'puppet_module_id': $scope.$stateParams.puppetModuleId,
                'organization_id': CurrentOrganization
            };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.controllerName = 'katello_repositories';
        repositoriesNutupane.masterOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        $scope.table = repositoriesNutupane.table;
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModuleRepositoriesController', PuppetModuleRepositoriesController);

    PuppetModuleRepositoriesController.$inject = [
        '$scope',
        'Nutupane',
        'Repository',
        'CurrentOrganization'
    ];

})();
