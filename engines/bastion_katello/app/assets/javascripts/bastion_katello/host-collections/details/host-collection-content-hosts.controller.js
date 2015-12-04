/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostCollection
 * @requires ContentHost
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionContentHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection', 'CurrentOrganization', 'ContentHost',
    function ($scope, $location, translate, Nutupane, HostCollection, CurrentOrganization, ContentHost) {
        var params;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'host_collection_id': $scope.$stateParams.hostCollectionId
        };

        $scope.contentNutupane = new Nutupane(ContentHost, params);
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.detailsTable.closeItem = function () {};
        $scope.isRemoving = false;
        $scope.contentNutupane.setSearchKey('contentHostSearch');

        $scope.removeSelected = function () {
            var selected = _.pluck($scope.detailsTable.getSelected(), 'uuid');

            $scope.isRemoving = true;
            HostCollection.removeContentHosts({id: $scope.hostCollection.id, 'system_ids': selected}, function (data) {
                $scope.contentNutupane.table.selectAll(false);
                $scope.contentNutupane.refresh();

                angular.forEach(data.displayMessages.success, function (success) {
                    $scope.$parent.successMessages.push(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    $scope.$parent.errorMessages.push(error);
                });
                $scope.refreshHostCollection();

                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.$parent.errorMessages.push(translate("An error occurred removing the content hosts.") + response.data.displayMessage);
            });
        };

    }]
);
