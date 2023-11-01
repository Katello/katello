(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.files.controller:FilesController
     *
     * @description
     *   Handles fetching files and populating Nutupane based on the current
     *   ui-router state.
     *
     * @requires translate
     *
     */
    function FilesController($scope, Nutupane, File, CurrentOrganization, translate) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(File, params);
        $scope.controllerName = 'katello_files';

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Files');

        nutupane.primaryOnly = true;

        $scope.table = nutupane.table;
        $scope.controllerName = 'katello_files';
    }

    angular
        .module('Bastion.files')
        .controller('FilesController', FilesController);

    FilesController.$inject = ['$scope', 'Nutupane', 'File', 'CurrentOrganization', 'translate'];

})();
