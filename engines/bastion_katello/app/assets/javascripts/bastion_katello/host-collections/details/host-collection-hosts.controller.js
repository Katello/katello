/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires Notification
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Host
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionHostsController',
    ['$scope', '$location', 'Notification', 'translate', 'Nutupane', 'CurrentOrganization', 'Host', 'HostCollection',
    function ($scope, $location, Notification, translate, Nutupane, CurrentOrganization, Host, HostCollection) {
        var params, nutupaneParams;

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

        $scope.contentNutupane = new Nutupane(Host, params, undefined, nutupaneParams);
        $scope.controllerName = 'hosts';
        $scope.contentNutupane.searchTransform = function (term) {
            var addition = "host_collection_id=" + $scope.$stateParams.hostCollectionId;
            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }

            return term + " and " + addition;
        };

        $scope.table = $scope.contentNutupane.table;
        $scope.table.closeItem = function () {};
        $scope.isRemoving = false;
        $scope.contentNutupane.setSearchKey('contentHostSearch');
        $scope.contentNutupane.refresh();

        $scope.removeSelected = function () {
            var selected = _.map($scope.table.getSelected(), 'id');

            $scope.isRemoving = true;
            HostCollection.removeHosts({id: $scope.hostCollection.id, 'host_ids': selected}, function (data) {
                $scope.contentNutupane.table.selectAll(false);
                $scope.contentNutupane.refresh();

                angular.forEach(data.displayMessages.success, function (success) {
                    Notification.setSuccessMessage(success);
                });

                angular.forEach(data.displayMessages.error, function (error) {
                    Notification.setErrorMessage(error);
                });
                $scope.refreshHostCollection();

                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                Notification.setErrorMessage(translate("An error occurred removing the content hosts.") + response.data.displayMessage);
            });
        };

    }]
);
