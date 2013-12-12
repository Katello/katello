/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Bastion.systems.controller:SystemsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires gettext
 * @requires Nutupane
 * @requires BulkAction
 * @requires SystemGroup
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionGroupsController',
    ['$scope', '$q', '$location', 'gettext', 'Nutupane', 'BulkAction', 'SystemGroup', 'CurrentOrganization',
    function($scope, $q, $location, gettext, Nutupane, BulkAction, SystemGroup, CurrentOrganization) {

        $scope.systemGroups = {
            action: null
        };

        var params = {
            'organization_id':  CurrentOrganization,
            'offset':           0,
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        var groupNutupane = new Nutupane(SystemGroup, params);

        $scope.detailsTable = groupNutupane.table;
        $scope.detailsTable.closeItem = function() {};

        $scope.confirmSystemGroupAction = function(action) {
            $scope.systemGroups.confirm = true;
            $scope.systemGroups.action = action;
        };

        $scope.performSystemGroupAction = function() {
            var params, action, success, error, deferred = $q.defer();

            action = $scope.systemGroups.action;
            params = $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            params['system_group_ids'] = groupNutupane.getAllSelectedResults('id').included.ids;

            $scope.systemGroups.action = null;

            success = function(data) {
                deferred.resolve(data);
                $scope.systemGroups.working = false;

                $scope.successMessages = data["displayMessages"];
                $scope.errorMessages = [];
                groupNutupane.refresh();
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.systemGroups.working = false;
                $scope.editMode = true;
                _.each(error.data.errors, function(errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred: ") + errorMessage);
                });
            };

            if (action === 'add') {
                BulkAction.addSystemGroups(params, success, error);
            } else if (action === 'remove') {
                BulkAction.removeSystemGroups(params, success, error);
            }

            return deferred.promise;
        };

    }]
);
