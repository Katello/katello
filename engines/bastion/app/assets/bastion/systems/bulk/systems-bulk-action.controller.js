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
 * @requires BulkAction
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionController',
    ['$scope', '$q', '$location', 'BulkAction',
    function($scope, $q, $location, BulkAction) {

        $scope.removeSystems = {
            confirm: false,
            workingMode: false
        };

        $scope.status = {
            showSuccess: false,
            showError: false,
            success: '',
            errors: []
        };

        $scope.actionParams = {
            ids: []
        };

        $scope.performRemoveSystems = function() {
            var success, error, deferred = $q.defer();

            $scope.removeSystems.confirm = false;
            $scope.removeSystems.workingMode = true;

            $scope.actionParams.ids = $scope.getSelectedSystemIds();

            success = function(data) {
                deferred.resolve(data);
                angular.forEach($scope.systemTable.getSelected(), function(row) {
                    $scope.removeRow(row.id);
                });

                $scope.removeSystems.workingMode = false;
                $scope.status.success = data["displayMessage"];
                $scope.status.showSuccess = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.removeSystems.workingMode = false;
                $scope.status.showError = true;
                $scope.status.errors = error.data["errors"];
            };

            BulkAction.removeSystems($scope.actionParams, success, error);

            return deferred.promise;
        };

        $scope.getSelectedSystemIds = function() {
            var rows = $scope.systemTable.getSelected();
            return _.pluck(rows, 'id');
        };

    }]
);
