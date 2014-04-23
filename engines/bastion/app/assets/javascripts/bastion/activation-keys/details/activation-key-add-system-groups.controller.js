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
 * @name  Bastion.systems.controller:ActivationKeyAddSystemGroupsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding system groups to an activation key.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAddSystemGroupsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane) {
        var systemGroupsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true,
            'id':          $scope.$stateParams.activationKeyId
        };

        systemGroupsPane = new Nutupane(ActivationKey, params, 'availableSystemGroups');
        $scope.systemGroupsTable = systemGroupsPane.table;

        $scope.addSystemGroups = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                systemGroupsToAdd = _.pluck($scope.systemGroupsTable.getSelected(), 'id');

            data = {
                "activation_key": {
                    "system_group_ids": systemGroupsToAdd
                }
            };

            success = function (data) {
                $scope.successMessages = [translate('Added %x system groups to activation key "%y".')
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
                $scope.errorMessages = error.data.errors['base'];
                $scope.systemGroupsTable.working = false;
            };

            $scope.systemGroupsTable.working = true;
            ActivationKey.addSystemGroups({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
