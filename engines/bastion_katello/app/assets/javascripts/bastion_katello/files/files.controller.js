(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.puppet-modules.controller:FilesController
     *
     * @description
     *   Handles fetching puppet modules content and populating Nutupane based on the current
     *   ui-router state.
     */
    function FilesController($scope, Nutupane, File, CurrentOrganization) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(File, params);
        $scope.controllerName = 'katello_files';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.controllerName = 'katello_files';
    }

    angular
        .module('Bastion.files')
        .controller('FilesController', FilesController);

    FilesController.$inject = ['$scope', 'Nutupane', 'File', 'CurrentOrganization'];

})();
