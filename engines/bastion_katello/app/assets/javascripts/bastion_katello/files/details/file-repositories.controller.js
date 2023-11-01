(function () {

    /**
     * @ngdoc object
     * @name  Bastion.files.controller:FileRepositoriesController
     *
     * @description
     *   Provides the functionality for the files details repositories page.
     *
     * @requires translate
     *
     */
    function FileRepositoriesController($scope, Nutupane, Repository, CurrentOrganization, translate) {
        var repositoriesNutupane,
            params = {
                'file_id': $scope.$stateParams.fileId,
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
        .module('Bastion.files')
        .controller('FileRepositoriesController', FileRepositoriesController);

    FileRepositoriesController.$inject = [
        '$scope',
        'Nutupane',
        'Repository',
        'CurrentOrganization'
    ];

})();
