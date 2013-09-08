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
 * @requires i18nFilter
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionController',
    ['$scope', '$q', 'BulkAction', 'SystemGroup', 'i18nFilter',
    function($scope, $q, BulkAction, SystemGroup, i18nFilter) {

        $scope.actionResource = new BulkAction();

        $scope.status = {
            success: false,
            error: false,
            displayMessage: ''
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

        $scope.removeSystems = function() {
            var success, error, deferred = $q.defer();

            $scope.removeSystems.confirm = false;
            $scope.removeSystems.workingMode = true;

            $scope.actionResource.ids = $scope.getSelectedSystemIds();

            success = function(data) {
                deferred.resolve(data);
                angular.forEach($scope.table.getSelected(), function(row) {
                    $scope.removeRow(row);
                });

                $scope.removeSystems.workingMode = false;
                $scope.status.displayMessage = data["displayMessage"];
                $scope.status.success = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.removeSystems.workingMode = false;
                $scope.status.error = true;
                $scope.status.displayMessage = error.data["displayMessage"];
            };

            $scope.actionResource.$removeSystems({}, success, error);

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

            $scope.actionResource['ids'] = $scope.getSelectedSystemIds();
            $scope.actionResource['system_group_ids'] = _.pluck($scope.systemGroups.groups, "id");

            success = function(data) {
                deferred.resolve(data);
                $scope.systemGroups.workingMode = false;
                $scope.editMode = true;
                $scope.status.displayMessage = data["displayMessage"];
                $scope.status.success = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.systemGroups.workingMode = false;
                $scope.editMode = true;
                $scope.status.error = true;
                $scope.status.displayMessage = error.data["displayMessage"];
            };

            if ($scope.systemGroups.action === 'add') {
                $scope.actionResource.$addSystemGroups({}, success, error);
            } else if ($scope.systemGroups.action === 'remove') {
                $scope.actionResource.$removeSystemGroups({}, success, error);
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
            if ($scope.content.action === "install") {
                installContent($scope.content);
            } else if ($scope.content.action === "update") {
                updateContent($scope.content);
            } else if ($scope.content.action === "remove") {
                removeContent($scope.content);
            }
        };

        $scope.getSelectedSystemIds = function() {
            var rows = $scope.table.getSelected(), filteredRows;

            filteredRows = _.filter(rows, function(row) {
                if (row !== undefined) {
                    return row;
                }
            });

            return _.pluck(filteredRows, 'id');
        };

        function installContent(content) {
            var success, error, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.content.workingMode = true;

            success = function(data) {
                deferred.resolve(data);
                $scope.content.workingMode = false;
                $scope.status.displayMessage = data["displayMessage"];
                $scope.status.success = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.content.workingMode = false;
                $scope.status.error = true;
                $scope.status.displayMessage = error.data["displayMessage"];
            };

            initContentAction(content);
            $scope.actionResource.$installContent({}, success, error);

            return deferred.promise;
        }

        function updateContent(content) {
            var success, error, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.content.workingMode = true;

            success = function(data) {
                deferred.resolve(data);
                $scope.content.workingMode = false;
                $scope.status.displayMessage = data["displayMessage"];
                $scope.status.success = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.content.workingMode = false;
                $scope.status.error = true;
                $scope.status.displayMessage = error.data["displayMessage"];
            };

            initContentAction(content);
            $scope.actionResource.$updateContent({}, success, error);

            return deferred.promise;
        }

        function removeContent(content) {
            var success, error, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.content.workingMode = true;

            success = function(data) {
                deferred.resolve(data);
                $scope.content.workingMode = false;
                $scope.status.displayMessage = data["displayMessage"];
                $scope.status.success = true;
            };

            error = function(error) {
                deferred.reject(error.data["errors"]);
                $scope.content.workingMode = false;
                $scope.status.error = true;
                $scope.status.displayMessage = error.data["displayMessage"];
            };

            initContentAction(content);
            $scope.actionResource.$removeContent({}, success, error);

            return deferred.promise;
        }

        function initContentAction(content) {
            $scope.actionResource['content_type'] = content.contentType;
            $scope.actionResource['content'] = content.content.split(/ *, */);
            $scope.actionResource['ids'] = $scope.getSelectedSystemIds();
        }

    }]
);
