/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionAddHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Host
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection add content hosts pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionAddHostsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Host', 'HostCollection',
    function ($scope, $state, $location, translate, Nutupane, CurrentOrganization, Host, HostCollection) {
        var addHostsPane, params;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        addHostsPane = new Nutupane(Host, params);
        addHostsPane.searchTransform = function (term) {
            var addition = "-host_collection_id=" + $scope.$stateParams.hostCollectionId;
            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }

            return term + " " + addition;
        };

        $scope.addHostsTable = addHostsPane.table;
        $scope.isAdding = false;
        $scope.addHostsTable.closeItem = function () {};

        $scope.disableAddButton = function () {
            return $scope.addHostsTable.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = _.pluck($scope.addHostsTable.getSelected(), 'id');

            $scope.isAdding = true;
            HostCollection.addHosts({id: $scope.hostCollection.id, 'host_ids': selected}, function (data) {
                angular.forEach(data.displayMessages.success, function (success) {
                    $scope.$parent.successMessages.push(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    $scope.$parent.errorMessages.push(error);
                });

                $scope.isAdding = false;
                addHostsPane.refresh();
                $scope.refreshHostCollection();
            }, function (response) {
                $scope.$parent.errorMessages.push(response.data.displayMessage);
                $scope.isAdding = false;
            });
        };

    }]
);
