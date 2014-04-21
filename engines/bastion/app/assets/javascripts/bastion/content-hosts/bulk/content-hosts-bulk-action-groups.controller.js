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
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ContentHostsBulkAction
 * @requires SystemGroup
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionGroupsController',
    ['$scope', '$q', '$location', 'translate', 'Nutupane', 'ContentHostBulkAction', 'SystemGroup', 'CurrentOrganization',
    function ($scope, $q, $location, translate, Nutupane, ContentHostBulkAction, SystemGroup, CurrentOrganization) {
        var groupNutupane, params;

        $scope.systemGroups = {
            action: null
        };
        $scope.setState(false, [], []);

        params = {
            'organization_id':  CurrentOrganization,
            'offset':           0,
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        groupNutupane = new Nutupane(SystemGroup, params);

        $scope.setState(false, [], []);
        $scope.detailsTable = groupNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.confirmSystemGroupAction = function (action) {
            $scope.systemGroups.confirm = true;
            $scope.systemGroups.action = action;
        };

        $scope.performSystemGroupAction = function () {
            var params, action, success, error, deferred = $q.defer();

            action = $scope.systemGroups.action;
            params = $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            params['system_group_ids'] = groupNutupane.getAllSelectedResults('id').included.ids;

            $scope.systemGroups.action = null;
            $scope.setState(true, [], []);

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, data["displayMessages"], []);
                groupNutupane.refresh();
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.setState(false, [], [error.data.displayMessage]);
                $scope.editMode = true;
            };

            if (action === 'add') {
                ContentHostBulkAction.addSystemGroups(params, success, error);
            } else if (action === 'remove') {
                ContentHostBulkAction.removeSystemGroups(params, success, error);
            }

            return deferred.promise;
        };

    }]
);
