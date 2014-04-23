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
 * @name  Bastion.system-groups.controller:SystemGroupContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires SystemGroup
 *
 * @description
 *   Provides the functionality for the system group details action pane.
 */
angular.module('Bastion.system-groups').controller('SystemGroupContentHostsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'SystemGroup',
    function ($scope, $location, translate, Nutupane, SystemGroup) {
        var contentHostsPane, params;

        params = {
            'id':          $scope.$stateParams.systemGroupId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        contentHostsPane = new Nutupane(SystemGroup, params, 'contentHosts');
        $scope.contentHostsTable = contentHostsPane.table;
        $scope.contentHostsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.removeSelected = function () {
            var selected = _.pluck($scope.contentHostsTable.getSelected(), 'uuid');

            $scope.isRemoving = true;
            SystemGroup.removeContentHosts({id: $scope.group.id, 'system_ids': selected}, function () {
                contentHostsPane.table.selectAll(false);
                contentHostsPane.refresh();
                $scope.successMessages.push(translate("Successfully removed %s content hosts.").replace('%s', selected.length));
                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(translate("An error occurred removing the content hosts.") + response.data.displayMessage);
            });
        };

    }]
);
