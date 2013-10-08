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
 * @name  Bastion.notices.controller:NoticesController
 *
 * @requires $scope
 * @requires $state
 * @requires Nutupane
 * @requires BulkAction
 * @requires Routes
 *
 * @description
 *   Provides the functionality specific to Notices for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.notices').controller('NoticesController',
    ['$scope', '$state', '$location', 'Nutupane', 'BulkAction', 'Notice', 'CurrentOrganization',
    function($scope, $state, $location, Nutupane, BulkAction, Notice, CurrentOrganization) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'offset':           0,
            'sort_by':          'created_at',
            'sort_order':       'DESC',
            'paged':            true
        };

        var nutupane = new Nutupane(Notice, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;

        $scope.table.openDetails = function (notice) {
            $scope.transitionTo('notices.details.info', {noticeId: notice.id});
        };

        $scope.table.closeItem = function() {
            $scope.transitionTo('notices.index');
        };

        $scope.actionParams = {
            ids: []
        };

        $scope.status = {
            showSuccess: false,
            showError: false,
            success: '',
            errors: []
        };

        $scope.removeNotices = {
            confirm: false,
            workingMode: false
        };

        $scope.removeNotices.disabled = function() {
            return $scope.removeNotices.workingMode || $scope.getSelectedNoticeIds().length < 1;
        };

        $scope.performRemoveNotices = function() {
            var success, error, deferred = $q.defer();

            $scope.removeNotices.confirm = false;
            $scope.removeNotices.workingMode = true;

            $scope.actionParams.ids = $scope.getSelectedNoticeIds();

            success = function(data) {
                deferred.resolve(data);
                angular.forEach($scope.table.getSelected(), function(row) {
                    $scope.removeRow(row);
                });

                $scope.removeNotices.workingMode = false;
                $scope.status.success = data["displayMessage"];
                $scope.status.showSuccess = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.removeNotices.workingMode = false;
                $scope.status.showError = true;
                $scope.status.errors = error.data["errors"];
            };

            BulkAction.removeNotices($scope.actionParams, success, error);

            return deferred.promise;
        };

        $scope.getSelectedNoticeIds = function() {
            var rows = $scope.table.getSelected();
            return _.pluck(rows, 'id');
        };
    }]
);
