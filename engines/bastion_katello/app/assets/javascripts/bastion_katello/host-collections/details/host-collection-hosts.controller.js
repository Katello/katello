/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection',
    function ($scope, $location, translate, Nutupane, HostCollection) {
        var hostsPane, params;

        params = {
            'id': $scope.$stateParams.hostCollectionId,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        hostsPane = new Nutupane(HostCollection, params, 'hosts');
        $scope.hostsTable = hostsPane.table;
        $scope.hostsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.removeSelected = function () {
            var selected = _.pluck($scope.hostsTable.getSelected(), 'id');

            $scope.isRemoving = true;
            HostCollection.removeHosts({id: $scope.hostCollection.id, 'host_ids': selected}, function (data) {
                hostsPane.table.selectAll(false);
                hostsPane.refresh();

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
