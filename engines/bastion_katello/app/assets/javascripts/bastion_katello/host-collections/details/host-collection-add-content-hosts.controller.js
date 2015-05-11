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
        var addContentHostsPane, params;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        addContentHostsPane = new Nutupane(ContentHost, params);
        addContentHostsPane.searchTransform = function (term) {
            var addition = "NOT ( host_collection_ids:" + $scope.$stateParams.hostCollectionId + " )";
            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }

            return term + " " + addition;
        };

        $scope.addContentHostsTable = addContentHostsPane.table;
        $scope.isAdding = false;
        $scope.addContentHostsTable.closeItem = function () {};

        $scope.disableAddButton = function () {
            return $scope.addContentHostsTable.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = _.pluck($scope.addContentHostsTable.getSelected(), 'uuid');

            $scope.isAdding = true;
            HostCollection.addContentHosts({id: $scope.hostCollection.id, 'system_ids': selected}, function (data) {
                angular.forEach(data.displayMessages.success, function (success) {
                    $scope.$parent.successMessages.push(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    $scope.$parent.errorMessages.push(error);
                });

                $scope.isAdding = false;
                addContentHostsPane.refresh();
                $scope.refreshHostCollection();
            }, function (response) {
                $scope.$parent.errorMessages.push(response.data.displayMessage);
                $scope.isAdding = false;
            });
        };

    }]
);
