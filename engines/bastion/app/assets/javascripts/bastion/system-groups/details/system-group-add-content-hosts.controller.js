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
 * @name  Bastion.system-groups.controller:SystemGroupAddContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentHost
 * @requires SystemGroup
 *
 * @description
 *   Provides the functionality for the system group add content hosts pane.
 */
angular.module('Bastion.system-groups').controller('SystemGroupAddContentHostsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'ContentHost', 'SystemGroup',
    function ($scope, $state, $location, translate, Nutupane, CurrentOrganization, ContentHost, SystemGroup) {

        var addContentHostsPane, params;

        params = {
            'organization_id':          CurrentOrganization,
            'search':                   $location.search().search || "",
            'page':                     1,
            'sort_by':                  'name',
            'sort_order':               'ASC',
            'paged':                    true
        };

        addContentHostsPane = new Nutupane(ContentHost, params);
        addContentHostsPane.searchTransform = function (term) {
            var addition = "NOT ( system_group_ids:" + $scope.$stateParams.systemGroupId + " )";
            if (term === "" || term === undefined) {
                return addition;
            } else {
                return term +  " " + addition;
            }
        };

        $scope.addContentHostsTable = addContentHostsPane.table;
        $scope.isAdding  = false;
        $scope.addContentHostsTable.closeItem = function () {};

        $scope.showAddButton = function () {
            return $scope.addContentHostsTable.numSelected === 0 || $scope.isAdding || !$scope.group.permissions.editable;
        };

        $scope.addSelected = function () {
            var selected;
            selected = _.pluck($scope.addContentHostsTable.getSelected(), 'uuid');

            $scope.isAdding = true;
            SystemGroup.addContentHosts({id: $scope.group.id, 'system_ids': selected}, function () {
                $scope.successMessages.push(translate("Successfully added %s content hosts.").replace('%s', selected.length));
                $scope.isAdding = false;
                addContentHostsPane.refresh();
            }, function (response) {
                $scope.$parent.errorMessages = response.data.displayMessage;
                $scope.isAdding  = false;
            });
        };

    }]
);
