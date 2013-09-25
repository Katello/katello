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
 * @requires BulkAction
 * @requires SystemGroup
 * @requires Organization
 * @requires Task
 * @requires i18nFilter
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionController',
    ['$scope', '$q', 'BulkAction', 'SystemGroup', 'i18nFilter',
     'Organization', 'Task',
    function($scope, $q, BulkAction, SystemGroup, i18nFilter,
        Organization, Task) {

        $scope.actionParams = {
            ids: []
        };

        $scope.status = {
            showSuccess: false,
            showError: false,
            success: '',
            errors: []
        };

        $scope.removeSystems = {
            confirm: false,
            workingMode: false
        };

        $scope.systemGroups = {
            confirm: false,
            workingMode: false,
            groups: []
        };

        $scope.content = {
            confirm: false,
            workingMode: false,
            placeholder: i18nFilter('Enter Package Name(s)...'),
            contentType: 'package'
        };

        $scope.subscription = {
            confirm: false,
            workingMode: false
        };

        $scope.performRemoveSystems = function() {
            var success, error, deferred = $q.defer();

            $scope.removeSystems.confirm = false;
            $scope.removeSystems.workingMode = true;

            $scope.actionParams.ids = $scope.getSelectedSystemIds();

            success = function(data) {
                deferred.resolve(data);
                angular.forEach($scope.table.getSelected(), function(row) {
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

        $scope.getSystemGroups = function() {
            var deferred = $q.defer();

            SystemGroup.query(function(systemGroups) {
                deferred.resolve(systemGroups);
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
                $scope.status.success = data["displayMessage"];
                $scope.status.showSuccess = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.systemGroups.workingMode = false;
                $scope.editMode = true;
                $scope.status.showError = true;
                $scope.status.errors = error.data["errors"];
            };

            if ($scope.systemGroups.action === 'add') {
                BulkAction.addSystemGroups($scope.actionParams, success, error);
            } else if ($scope.systemGroups.action === 'remove') {
                BulkAction.removeSystemGroups($scope.actionParams, success, error);
            }

            return deferred.promise;
        };

        $scope.updatePlaceholder = function(contentType) {
            if (contentType === "package") {
                $scope.content.placeholder = i18nFilter('Enter Package Name(s)...');
            } else if (contentType === "package_group") {
                $scope.content.placeholder = i18nFilter('Enter Package Group Name(s)...');
            } else {
                $scope.content.placeholder = i18nFilter('Enter Errata ID(s)...');
            }
        };

        $scope.confirmContentAction = function(action, actionInput) {
            $scope.content.confirm = true;
            $scope.content.action = action;
            $scope.content.actionInput = actionInput;
        };

        $scope.performContentAction = function() {
            var success, error, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.content.workingMode = true;

            success = function(data) {
                deferred.resolve(data);
                $scope.content.workingMode = false;
                $scope.status.success = data["displayMessage"];
                $scope.status.showSuccess = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.content.workingMode = false;
                $scope.status.showError = true;
                $scope.status.errors = error.data["errors"];
            };

            initContentAction($scope.content);

            if ($scope.content.action === "install") {
                BulkAction.installContent($scope.actionParams, success, error);
            } else if ($scope.content.action === "update") {
                BulkAction.updateContent($scope.actionParams, success, error);
            } else if ($scope.content.action === "remove") {
                BulkAction.removeContent($scope.actionParams, success, error);
            }

            return deferred.promise;
        };

        $scope.getSelectedSystemIds = function() {
            var rows = $scope.table.getSelected();
            return _.pluck(rows, 'id');
        };

        $scope.performAutoAttachSubscriptions = function() {
            var success, error, deferred = $q.defer();

            $scope.subscription.confirm = false;
            $scope.subscription.workingMode = true;

            success = function(scheduledTask) {
                deferred.resolve(scheduledTask);
                $scope.subscription.autoAttachTask = scheduledTask;
                Task.poll(scheduledTask, function(polledTask) {
                    $scope.subscription.autoAttachTask = polledTask;
                    $scope.subscription.workingMode = false;
                });
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.subscription.workingMode = false;
            };

            Organization.autoAttach({}, success, error);

            return deferred.promise;
        };

        function initContentAction(content) {
            $scope.actionParams['content_type'] = content.contentType;
            $scope.actionParams['content'] = content.content.split(/ *, */);
            $scope.actionParams['ids'] = $scope.getSelectedSystemIds();
        }

        function autoAttachSubscriptionsInProgress() {
            // Check to see if an 'auto attach subscriptions' action is currently in progress.
            // If it is, poll on the associated task, until it is completed.
            Organization.query(function(organization) {
                if (organization['owner_auto_attach_all_systems_task_id'] !== null) {

                    Task.query({'id' : organization['owner_auto_attach_all_systems_task_id']}, function(task) {
                        $scope.subscription.autoAttachTask = task;

                        if (task.pending) {
                            $scope.subscription.workingMode = true;
                            Task.poll(task, function(polledTask) {
                                $scope.subscription.autoAttachTask = polledTask;
                                $scope.subscription.workingMode = false;
                            });
                        }
                    });
                }
            });
        }
        autoAttachSubscriptionsInProgress();
    }]
);
