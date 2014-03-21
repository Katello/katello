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
 * @name  Bastion.systems.controller:SystemAddaddSystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires gettext
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding system groups to a system.
 */
angular.module('Bastion.systems').controller('SystemAddSystemGroupsController',
    ['$scope', '$q', '$location', 'gettext', 'System', 'Nutupane',
    function ($scope, $q, $location, gettext, System, Nutupane) {
        var systemGroupsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true,
            'id':            $scope.$stateParams.systemId
        };

        systemGroupsPane = new Nutupane(System, params, 'availableSystemGroups');
        $scope.systemGroupsTable = systemGroupsPane.table;

        $scope.addSystemGroups = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                systemGroups = _.pluck($scope.system.systemGroups, 'id'),
                systemGroupsToAdd = _.pluck($scope.systemGroupsTable.getSelected(), 'id');

            data = {
                system: {
                    "system_group_ids": _.union(systemGroups, systemGroupsToAdd)
                }
            };

            success = function (data) {
                $scope.successMessages = [gettext('Added %x system groups to system "%y".')
                    .replace('%x', $scope.systemGroupsTable.numSelected).replace('%y', $scope.system.name)];
                $scope.systemGroupsTable.working = false;
                $scope.systemGroupsTable.selectAll(false);
                systemGroupsPane.refresh();
                $scope.system.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                $scope.errorMessages = error.data.errors['base'];
                $scope.systemGroupsTable.working = false;
            };

            $scope.systemGroupsTable.working = true;
            System.saveSystemGroups({id: $scope.system.uuid}, data, success, error);
            return deferred.promise;
        };
    }]
);
