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
 * @requires BulkAction
 * @requires SystemGroup
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionGroupsController',
    ['$scope', '$q', '$location', 'gettext', 'BulkAction', 'SystemGroup', 'CurrentOrganization',
    function($scope, $q, $location, gettext, BulkAction, SystemGroup, CurrentOrganization) {

        $scope.actionParams = {
            ids: []
        };

        $scope.systemGroups = {
            confirm: false,
            workingMode: false,
            groups: []
        };

        $scope.getSystemGroups = function() {
            var deferred = $q.defer();

            SystemGroup.query({'organization_id': CurrentOrganization}, function(systemGroups) {
                deferred.resolve(systemGroups.results);
            });

            return deferred.promise;
        };

        $scope.confirmSystemGroupAction = function(action) {
            $scope.systemGroups.confirm = true;
            $scope.systemGroups.action = action;
        };

        $scope.performSystemGroupAction = function() {
            var success, error, deferred = $q.defer();

            $scope.systemGroups.confirm = false;
            $scope.systemGroups.workingMode = true;
            $scope.editMode = false;

            $scope.actionParams['ids'] = $scope.getSelectedSystemIds();
            $scope.actionParams['system_group_ids'] = _.pluck($scope.systemGroups.groups, "id");

            success = function(data) {
                deferred.resolve(data);
                $scope.systemGroups.workingMode = false;
                $scope.editMode = true;
                $scope.successMessages.push(data["displayMessage"]);
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.systemGroups.workingMode = false;
                $scope.editMode = true;
                _.each(error.data.errors, function(errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred: ") + errorMessage);
                });
            };

            if ($scope.systemGroups.action === 'add') {
                BulkAction.addSystemGroups($scope.actionParams, success, error);
            } else if ($scope.systemGroups.action === 'remove') {
                BulkAction.removeSystemGroups($scope.actionParams, success, error);
            }

            return deferred.promise;
        };

    }]
);
