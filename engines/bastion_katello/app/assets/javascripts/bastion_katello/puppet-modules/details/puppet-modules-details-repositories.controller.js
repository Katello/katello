(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModulesDetailsRepositoriesController
     *
     * @description
     *   Provides the functionality for the puppet modules details repositories page.
     */
    function PuppetModulesDetailsRepositoriesController($scope, Nutupane, Repository, CurrentOrganization) {
        var repositoriesNutupane,
            params = {
                'puppet_module_id': $scope.$stateParams.puppetModuleId,
                'organization_id': CurrentOrganization
            };

        repositoriesNutupane = new Nutupane(Repository, params);
        repositoriesNutupane.masterOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        $scope.detailsTable = repositoriesNutupane.table;
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModulesDetailsRepositoriesController', PuppetModulesDetailsRepositoriesController);

    PuppetModulesDetailsRepositoriesController.$inject = [
        '$scope',
        'Nutupane',
        'Repository',
        'CurrentOrganization'
    ];

})();
