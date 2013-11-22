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
 * @name  Bastion.systems.controller:SystemGroupDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires SystemGroup
 *
 * @description
 *   Provides the functionality for the system group details action pane.
 */
angular.module('Bastion.system-groups').controller('SystemGroupDetailsController',
    ['$scope', '$state', '$q', 'SystemGroup',
    function($scope, $state, $q, SystemGroup) {

        if ($scope.group) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.group = SystemGroup.get({id: $scope.$stateParams.systemGroupId}, function(group) {
            $scope.$broadcast('group.loaded', group);
            $scope.panel.loading = false;
        });

        $scope.save = function(group) {
            var deferred = $q.defer();

            group.$update(function(response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
                $scope.saveError = false;
            }, function(response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.saveSuccess = false;
                $scope.errors = response.data.displayMessage;
            });
            return deferred.promise;
        };

        $scope.copy = function(newName) {
            SystemGroup.copy({id: $scope.group.id, 'system_group': {name: newName}}, function(response) {
                $scope.showCopy = false;
                $scope.copyError = false;
                $scope.table.addRow(response);
                $scope.transitionTo('system-groups.details.info', {systemGroupId: response['id']});
            }, function(response) {
                $scope.copyError = response.data.displayMessage;
            });
        };

        $scope.removeGroup = function(group) {
            var id = group.id;

            group.$delete(function() {
                $scope.removeRow(id);
                $scope.transitionTo('system-groups.index');
            }, function(response) {
                $scope.removeError = response.data.displayMessage;
            });
        };

    }]
);
