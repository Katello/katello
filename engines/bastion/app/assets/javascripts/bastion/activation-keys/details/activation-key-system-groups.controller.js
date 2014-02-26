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
 * @name  Bastion.systems.controller:ActivationKeySystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires gettext
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list system groups details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeySystemGroupsController',
    ['$scope', '$q', '$location', 'gettext', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, gettext, ActivationKey, Nutupane) {
        var systemGroupsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'id':          $scope.$stateParams.activationKeyId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        systemGroupsPane = new Nutupane(ActivationKey, params, 'systemGroups');
        $scope.systemGroupsTable = systemGroupsPane.table;

        $scope.removeSystemGroups = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                systemGroupsToRemove = _.pluck($scope.systemGroupsTable.getSelected(), 'id');

            data = {
                "activation_key": {
                    "system_group_ids": systemGroupsToRemove
                }
            };

            success = function (data) {
                $scope.successMessages = [gettext('Removed %x system groups from activation key "%y".')
                    .replace('%x', $scope.systemGroupsTable.numSelected)
                    .replace('%y', $scope.activationKey.name)];
                $scope.systemGroupsTable.working = false;
                $scope.systemGroupsTable.selectAll(false);
                systemGroupsPane.refresh();
                $scope.activationKey.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                $scope.errorMessages = error.data.errors;
                $scope.systemGroupsTable.working = false;
            };

            $scope.systemGroupsTable.working = true;
            ActivationKey.removeSystemGroups({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
