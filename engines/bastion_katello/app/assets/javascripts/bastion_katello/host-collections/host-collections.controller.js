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
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection', 'CurrentOrganization', 'urlencodeFilter',
    function ($scope, $location, translate, Nutupane, HostCollection, CurrentOrganization, urlencodeFilter) {

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        var nutupane = new Nutupane(HostCollection, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;
        $scope.controllerName = 'katello_host_collections';

        $scope.table.closeItem = function () {
            $scope.transitionTo('host-collections.index');
        };

        $scope.getHostCollectionSearchUrl = function (hostCollectionName) {
            var search = 'host_collection="%s"'.replace('%s', hostCollectionName);
            return '?select_all=true&search=' + urlencodeFilter(search);
        };

        $scope.$on("updateContentHostCollection", function (event, hostCollectionRow) {
            $scope.table.replaceRow(hostCollectionRow);
        });

    }]
);
