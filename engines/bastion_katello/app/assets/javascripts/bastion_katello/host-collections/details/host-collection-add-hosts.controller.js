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
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the host collection add content hosts pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionAddHostsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Host', 'HostCollection', 'Notification',
    function ($scope, $state, $location, translate, Nutupane, CurrentOrganization, Host, HostCollection, Notification) {
        var contentNutupane, params, nutupaneParams;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        nutupaneParams = {
            'disableAutoLoad': true
        };
        contentNutupane = new Nutupane(Host, params, undefined, nutupaneParams);
        $scope.controllerName = 'hosts';
        contentNutupane.searchTransform = function (term) {
            var addition = "-host_collection_id=" + $scope.$stateParams.hostCollectionId;
            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }

            return term + " and " + addition;
        };

        contentNutupane.refresh();
        $scope.table = contentNutupane.table;
        $scope.isAdding = false;
        $scope.table.closeItem = function () {};

        $scope.disableAddButton = function () {
            return $scope.table.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = _.map($scope.table.getSelected(), 'id');

            $scope.isAdding = true;
            HostCollection.addHosts({id: $scope.hostCollection.id, 'host_ids': selected}, function (data) {
                angular.forEach(data.displayMessages.success, function (success) {
                    Notification.setSuccessMessage(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    Notification.setErrorMessage(error);
                });

                $scope.isAdding = false;
                contentNutupane.refresh();
                $scope.refreshHostCollection();
            }, function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
                $scope.isAdding = false;
            });
        };

    }]
);
