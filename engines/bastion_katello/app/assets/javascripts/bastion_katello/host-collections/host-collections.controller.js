/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to host collections for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.host-collections').controller('HostCollectionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, HostCollection, CurrentOrganization) {
        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        var nutupane = new Nutupane(HostCollection, params);
        $scope.controllerName = 'katello_host_collections';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.$on("updateContentHostCollection", function (event, hostCollectionRow) {
            $scope.table.replaceRow(hostCollectionRow);
        });

    }]
);
