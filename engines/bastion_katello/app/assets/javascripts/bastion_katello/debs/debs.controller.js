(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.debs.controller:DebsController
     *
     * @description
     *   Handles fetching deb packages and populating Nutupane based on the current
     *   ui-router state.
     *
     * @requires translate
     *
     */
    function DebsController($scope, $location, translate, Nutupane, Deb, CurrentOrganization) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'paged': true,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(Deb, params);
        nutupane.primaryOnly = true;

        $scope.table = nutupane.table;

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Debs');

        $scope.controllerName = 'katello_debs';

        Deb.queryPaged({'organization_id': CurrentOrganization}, function (result) {
            $scope.packageCount = result.total;
        });

        $scope.showApplicable = false;
        $scope.showUpgradable = false;

        $scope.toggleFilters = function () {
            if ($scope.showUpgradable === true) {
                $scope.showApplicable = true;
            }

            nutupane.table.params['packages_restrict_applicable'] = $scope.showApplicable;
            nutupane.table.params['packages_restrict_upgradable'] = $scope.showUpgradable;
            nutupane.refresh();
        };

    }

    angular
        .module('Bastion.debs')
        .controller('DebsController', DebsController);

    DebsController.$inject = ['$scope', '$location', 'translate', 'Nutupane', 'Deb', 'CurrentOrganization'];

})();
