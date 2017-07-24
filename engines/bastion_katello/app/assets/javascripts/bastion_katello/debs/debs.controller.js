(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.debs.controller:DebsController
     *
     * @description
     *   Handles fetching deb packages and populating Nutupane based on the current
     *   ui-router state.
     */
    function DebsController($scope, Nutupane, Deb, CurrentOrganization) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(Deb, params);
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.controllerName = 'katello_debs';
    }

    angular
        .module('Bastion.debs')
        .controller('DebsController', DebsController);

    DebsController.$inject = ['$scope', 'Nutupane', 'Deb', 'CurrentOrganization'];

})();
