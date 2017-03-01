(function () {

    /**
     * @ngdoc object
     * @name  Bastion.files.controller:FileRepositoriesController
     *
     * @description
     *   Provides the functionality for the files details repositories page.
     */
    function FileRepositoriesController($scope, Nutupane, Repository, CurrentOrganization) {
        var repositoriesNutupane,
            params = {
                'file_id': $scope.$stateParams.fileId,
                'organization_id': CurrentOrganization
            };

        repositoriesNutupane = new Nutupane(Repository, params);
        $scope.controllerName = 'katello_repositories';
        repositoriesNutupane.masterOnly = true;
        repositoriesNutupane.setSearchKey('repositoriesSearch');

        $scope.table = repositoriesNutupane.table;
    }

    angular
        .module('Bastion.files')
        .controller('FileRepositoriesController', FileRepositoriesController);

    FileRepositoriesController.$inject = [
        '$scope',
        'Nutupane',
        'Repository',
        'CurrentOrganization'
    ];

})();
