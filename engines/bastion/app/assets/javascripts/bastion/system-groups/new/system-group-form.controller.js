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
 * @name  Bastion.system-groups.controller:SystemGroupFormController
 *
 * @requires $scope
 * @requires $q
 * @requires SystemGroup
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to SystemGroups for creating a new group
 */
angular.module('Bastion.system-groups').controller('SystemGroupFormController',
    ['$scope', '$q', 'SystemGroup', 'CurrentOrganization',
    function ($scope, $q, SystemGroup, CurrentOrganization) {

        $scope.group = $scope.group || new SystemGroup();

        $scope.save = function (group) {
            group['organization_id'] = CurrentOrganization;
            group.$save(success, error);
        };

        $scope.unlimited = true;
        $scope.group['max_systems'] = -1;

        $scope.isUnlimited = function (group) {
            return group['max_systems'] === -1;
        };

        $scope.inputChanged = function (group) {
            if ($scope.isUnlimited(group)) {
                $scope.unlimited = true;
            }
        };

        $scope.unlimitedChanged = function (group) {
            if ($scope.isUnlimited(group)) {
                $scope.unlimited = false;
                group['max_systems'] = 1;
            }
            else {
                $scope.unlimited = true;
                group['max_systems'] = -1;
            }
        };

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('system-groups.details.info', {systemGroupId: $scope.group.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.groupForm[field].$setValidity('', false);
                $scope.groupForm[field].$error.messages = errors;
            });
        }

    }]
);
