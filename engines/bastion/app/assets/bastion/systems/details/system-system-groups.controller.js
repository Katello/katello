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
 * @name  Bastion.systems.controller:SystemSystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires gettext
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list system groups details action pane.
 */
angular.module('Bastion.systems').controller('SystemSystemGroupsController',
    ['$scope', '$q', '$location', 'gettext', 'System', 'Nutupane',
    function ($scope, $q, $location, gettext, System, Nutupane) {
        var systemGroupsPane, params;

        params = {
            'id':          $scope.$stateParams.systemId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        systemGroupsPane = new Nutupane(System, params, 'systemGroups');
        $scope.systemGroupsTable = systemGroupsPane.table;
        $scope.systemGroupsTable.closeItem = function () {};

        $scope.removeSystemGroups = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                systemGroups = _.pluck($scope.system.systemGroups, 'id'),
                systemGroupsToRemove = _.pluck($scope.systemGroupsTable.getSelected(), 'id');

            data = {
                system: {
                    "system_group_ids": _.difference(systemGroups, systemGroupsToRemove)
                }
            };

            success = function (data) {
                $scope.successMessages.push(gettext('Removed %x system groups from system "%y".')
                    .replace('%x', $scope.systemGroupsTable.numSelected).replace('%y', $scope.system.name));
                $scope.systemGroupsTable.working = false;
                $scope.systemGroupsTable.selectAll(false);
                systemGroupsPane.refresh();
                $scope.system.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                _.each(error.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred while removing System Groups: ") +
                        errorMessage);
                });
                $scope.systemGroupsTable.working = false;
            };

            $scope.systemGroupsTable.working = true;
            System.saveSystemGroups({id: $scope.system.uuid}, data, success, error);
            return deferred.promise;
        };
    }]
);
