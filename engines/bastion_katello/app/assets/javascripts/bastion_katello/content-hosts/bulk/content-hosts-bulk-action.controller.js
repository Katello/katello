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
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ContentHostBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionController',
    ['$scope', '$q', '$location', 'translate', 'ContentHostBulkAction', 'CurrentOrganization',
    function ($scope, $q, $location, translate, ContentHostBulkAction, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.showConfirm = false;

        $scope.unregisterContentHosts = {
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

        $scope.showConfirmDialog = function () {
            $scope.showConfirm = true;
        };

        $scope.hideConfirmDialog = function () {
            $scope.showConfirm = false;
        };

        $scope.actionParams = {
            ids: []
        };

        $scope.showNoSelectionWarning = function () {
            return $scope.nutupane.table.numSelected === 0 && !$scope.isState('content-hosts.bulk-actions.subscriptions') &&
                !$scope.isState('content-hosts.bulk-actions.task-details');
        };

        $scope.performUnregisterContentHosts = function () {
            var params, success, error, deferred = $q.defer();

            $scope.unregisterContentHosts.confirm = false;
            $scope.state.working = true;

            params = $scope.nutupane.getAllSelectedResults();
            params['organization_id'] = CurrentOrganization;

            success = function (data) {
                deferred.resolve(data);
                angular.forEach($scope.contentHostTable.getSelected(), function (row) {
                    $scope.removeRow(row.id);

                });
                $scope.setState(false, data.displayMessages.success, data.displayMessages.error);
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.setState(false, [], error.data["errors"]);
            };

            ContentHostBulkAction.unregisterContentHosts(params, success, error);

            return deferred.promise;
        };

    }]
);
