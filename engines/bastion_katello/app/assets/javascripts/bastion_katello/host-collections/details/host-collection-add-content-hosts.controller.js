/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionAddContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentHost
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection add content hosts pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionAddContentHostsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'ContentHost', 'HostCollection',
    function ($scope, $state, $location, translate, Nutupane, CurrentOrganization, ContentHost, HostCollection) {
        var params;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'available_for': 'host_collection',
            'host_collection_id': $scope.$stateParams.hostCollectionId
        };

        $scope.contentNutupane = new Nutupane(ContentHost, params);

        $scope.contentNutupane.masterOnly = true;
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.isAdding = false;
        $scope.contentNutupane.setSearchKey('contentHostSearch');

        $scope.disableAddButton = function () {
            return $scope.detailsTable.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = _.pluck($scope.detailsTable.getSelected(), 'uuid');

            $scope.isAdding = true;
            HostCollection.addContentHosts({id: $scope.hostCollection.id, 'system_ids': selected}, function (data) {
                angular.forEach(data.displayMessages.success, function (success) {
                    $scope.$parent.successMessages.push(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    $scope.$parent.errorMessages.push(error);
                });

                $scope.isAdding = false;
                $scope.contentNutupane.refresh();
                $scope.refreshHostCollection();
            }, function (response) {
                $scope.$parent.errorMessages.push(response.data.displayMessage);
                $scope.isAdding = false;
            });
        };

    }]
);
