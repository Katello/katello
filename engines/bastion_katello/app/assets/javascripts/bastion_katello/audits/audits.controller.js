(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.audits.controller:AuditsController
     *
     * @description
     *   Handles fetching audit packages and populating Nutupane based on the current
     *   ui-router state.
     */
    function AuditsController($scope, Nutupane, Audit, CurrentOrganization) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(Audit, params);
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.controllerName = 'katello_audits';
    }

    angular
        .module('Bastion.audits')
        .controller('AuditsController', AuditsController);

    AuditsController.$inject = ['$scope', 'Nutupane', 'Audit', 'CurrentOrganization'];

})();
