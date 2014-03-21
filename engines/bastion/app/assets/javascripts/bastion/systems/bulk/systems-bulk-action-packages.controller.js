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
 * @name  Bastion.systems.controller:SystemsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @resource $location
 * @requires SystemBulkAction
 * @requires SystemGroup
 * @requires CurrentOrganization
 * @requires gettext
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionPackagesController',
    ['$scope', '$q', '$location', 'SystemBulkAction', 'SystemGroup', 'CurrentOrganization', 'gettext',
    function ($scope, $q, $location, SystemBulkAction, SystemGroup, CurrentOrganization, gettext) {

        $scope.setState(false, [], []);

        $scope.content = {
            confirm: false,
            placeholder: gettext('Enter Package Name(s)...'),
            contentType: 'package'
        };

        $scope.updatePlaceholder = function (contentType) {
            if (contentType === "package") {
                $scope.content.placeholder = gettext('Enter Package Name(s)...');
            } else if (contentType === "package_group") {
                $scope.content.placeholder = gettext('Enter Package Group Name(s)...');
            }
        };

        $scope.confirmContentAction = function (action, actionInput) {
            $scope.content.confirm = true;
            $scope.content.action = action;
            $scope.content.actionInput = actionInput;
        };

        $scope.performContentAction = function () {
            var success, error, params, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.setState(true, [], []);

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, [successMessage($scope.content.action)], []);
            };

            error = function (error) {
                $scope.setState(false, [], error.data.errors);
                deferred.reject(error.data.errors);
            };

            params = installParams();
            if ($scope.content.action === "install") {
                SystemBulkAction.installContent(params, success, error);
            } else if ($scope.content.action === "update") {
                SystemBulkAction.updateContent(params, success, error);
            } else if ($scope.content.action === "remove") {
                SystemBulkAction.removeContent(params, success, error);
            }

            return deferred.promise;
        };

        function successMessage(type) {
            var messages = {
                install: gettext("Succesfully scheduled package installation"),
                update: gettext("Succesfully scheduled package update"),
                remove: gettext("Succesfully scheduled package removal")
            };
            return messages[type];
        }

        function installParams() {
            var params = $scope.nutupane.getAllSelectedResults();
            params['content_type'] = $scope.content.contentType;
            params['content'] = $scope.content.content.split(/ *, */);
            params['organization_id'] = CurrentOrganization;
            return params;
        }

    }]
);
