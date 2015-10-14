/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostCollection
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionContentHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection', 'ContentHostsHelper',
    function ($scope, $location, translate, Nutupane, HostCollection, ContentHostsHelper) {
        var contentHostsPane, params;

        params = {
            'id': $scope.$stateParams.hostCollectionId,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        contentHostsPane = new Nutupane(HostCollection, params, 'contentHosts');
        $scope.contentHostsTable = contentHostsPane.table;
        $scope.contentHostsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.getStatusColor = ContentHostsHelper.getStatusColor;

        $scope.removeSelected = function () {
            var selected = _.pluck($scope.contentHostsTable.getSelected(), 'uuid');

            $scope.isRemoving = true;
            HostCollection.removeContentHosts({id: $scope.hostCollection.id, 'system_ids': selected}, function (data) {
                contentHostsPane.table.selectAll(false);
                contentHostsPane.refresh();

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
