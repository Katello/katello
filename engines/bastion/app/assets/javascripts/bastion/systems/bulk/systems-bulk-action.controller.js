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
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionController',
    ['$scope', '$q', '$location', 'gettext', 'BulkAction', 'CurrentOrganization',
    function ($scope, $q, $location, gettext, BulkAction, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.removeSystems = {
            confirm: false,
            workingMode: false
        };

        $scope.state = {
            successMessages: [],
            errorMessages: [],
            working: false
        };

        $scope.setState = function (working, success, errors) {
            $scope.state.working = working;
            $scope.state.successMessages = success;
            $scope.state.errorMessages = errors;
        };

        $scope.actionParams = {
            ids: []
        };

        $scope.performRemoveSystems = function () {
            var params, success, error, deferred = $q.defer();

            $scope.removeSystems.confirm = false;
            $scope.state.working = true;

            params = $scope.nutupane.getAllSelectedResults();
            params['organization_id'] = CurrentOrganization;

            success = function (data) {
                deferred.resolve(data);
                angular.forEach($scope.systemTable.getSelected(), function (row) {
                    $scope.removeRow(row.id);

                });
                $scope.setState(false, data.displayMessages, []);
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.setState(false, [], error.data["errors"]);
            };

            BulkAction.removeSystems(params, success, error);

            return deferred.promise;
        };

    }]
);
