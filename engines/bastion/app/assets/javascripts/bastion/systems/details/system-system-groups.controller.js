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
 * @name  Bastion.systems.controller:SystemSystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list system groups details action pane.
 */
angular.module('Bastion.systems').controller('SystemSystemGroupsController',
    ['$scope', '$q', '$location', 'translate', 'System', 'Nutupane',
    function ($scope, $q, $location, translate, System, Nutupane) {
        var systemGroupsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'id':          $scope.$stateParams.systemId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        systemGroupsPane = new Nutupane(System, params, 'systemGroups');
        $scope.systemGroupsTable = systemGroupsPane.table;

        $scope.removeSystemGroups = function (system) {
            var deferred = $q.defer(),
                success,
                error,
                systemGroups,
                systemGroupsToRemove;

            success = function (data) {
                $scope.successMessages = [translate('Removed %x system groups from system "%y".')
                    .replace('%x', $scope.systemGroupsTable.numSelected).replace('%y', $scope.system.name)];
                $scope.systemGroupsTable.working = false;
                $scope.systemGroupsTable.selectAll(false);
                systemGroupsPane.refresh();
                $scope.system.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                $scope.errorMessages = error.data.errors;
                $scope.systemGroupsTable.working = false;
            };

            $scope.systemGroupsTable.working = true;

            systemGroups = _.pluck($scope.system.systemGroups, 'id');
            systemGroupsToRemove = _.pluck($scope.systemGroupsTable.getSelected(), 'id');
            system["system_group_ids"] = _.difference(systemGroups, systemGroupsToRemove);

            system.$update({id: $scope.system.uuid}, success, error);
            return deferred.promise;
        };
    }]
);
