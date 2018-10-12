/**
 * @ngdoc object
 * @name  Bastion.syncPlans.controller:SyncPlansController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires SyncPlan
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to Sync Plans for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.sync-plans').controller('SyncPlansController',
    ['$scope', '$location', 'translate', 'Nutupane', 'SyncPlan', 'CurrentOrganization',
        function ($scope, $location, translate, Nutupane, SyncPlan, CurrentOrganization) {
            var params, nutupane;

            params = {
                'organization_id': CurrentOrganization,
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC'
            };

            nutupane = new Nutupane(SyncPlan, params);
            $scope.controllerName = 'katello_sync_plans';
            nutupane.masterOnly = true;

            $scope.syncPlanTable = nutupane.table;
            $scope.removeRow = nutupane.removeRow;
            $scope.nutupane = nutupane;

            nutupane.enableSelectAllResults();

            if ($location.search()['select_all']) {
                nutupane.table.selectAllResults(true);
            }

            $scope.table = $scope.syncPlanTable;
        }]
);
