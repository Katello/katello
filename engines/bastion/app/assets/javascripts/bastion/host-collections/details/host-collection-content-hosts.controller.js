/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionContentHostsController
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
angular.module('Bastion.host-collections').controller('HostCollectionContentHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'HostCollection',
    function ($scope, $location, translate, Nutupane, HostCollection) {
        var contentHostsPane, params;

        params = {
            'id':          $scope.$stateParams.hostCollectionId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        contentHostsPane = new Nutupane(HostCollection, params, 'contentHosts');
        $scope.contentHostsTable = contentHostsPane.table;
        $scope.contentHostsTable.closeItem = function () {};
        $scope.isRemoving = false;

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

                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.$parent.errorMessages.push(translate("An error occurred removing the content hosts.") + response.data.displayMessage);
            });
        };

    }]
);
