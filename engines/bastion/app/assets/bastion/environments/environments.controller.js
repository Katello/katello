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
 * @name  Bastion.environments.controller:EnvironmentsController
 *
 * @requires $scope
 * @requires $timeout
 * @requires $http
 * @requires Routes
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the environments path page.
 */
angular.module('Bastion.environments').controller('EnvironmentsController',
    ['$scope', '$timeout', '$http', 'Routes', 'CurrentOrganization',
        function($scope, $timeout, $http, Routes, CurrentOrganization) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            if (!$scope.environmentsTable) {
                $scope.environmentsTable = {rows: []};
            }

            $http.get(Routes.apiOrganizationEnvironmentsPath(CurrentOrganization) + '/paths')
            .success(function(paths) {
                $scope.environmentsTable.rows = paths;
            });

            $scope.initiateCreatePath = function () {
                if ($scope.environmentsTable.rows[0].path.length > 1) {
                    $scope.environmentsTable.rows.unshift([]);
                    $scope.environmentsTable.rows[0].path = [$scope.environmentsTable.rows[1].path[0]];
                    $scope.environmentsTable.rows[0].permissions = $scope.environmentsTable.rows[1].permissions;
                }
                $scope.environmentsTable.rows[0].pathId = 0;
                $scope.environmentsTable.rows[0].showCreate = true;
            };

            $scope.readonly = function() {
                if ($scope.environmentsTable.rows.length > 0) {
                    return $scope.environmentsTable.rows[0].permissions.readonly;
                } else {
                    return false;
                }
            };
        }]
);
