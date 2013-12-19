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
 * @requires SystemGroup
 * @requires Organization
 * @requires gettext
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Bastion.systems').controller('SystemsBulkActionErrataController',
    ['$scope', '$q', '$location', 'BulkAction', 'SystemGroup', 'CurrentOrganization', 'gettext',
    function ($scope, $q, $location, BulkAction, SystemGroup, CurrentOrganization, gettext) {

        $scope.actionParams = {
            ids: []
        };

        $scope.content = {
            confirm: false,
            workingMode: false,
            placeholder: gettext('Enter Errata Ids(s)...'),
            contentType: 'errata'
        };

        $scope.confirmContentAction = function (action, actionInput) {
            $scope.content.confirm = true;
            $scope.content.action = action;
            $scope.content.actionInput = actionInput;
        };

        $scope.performContentAction = function () {
            var success, error, deferred = $q.defer();

            $scope.content.confirm = false;
            $scope.content.workingMode = true;

            success = function (data) {
                deferred.resolve(data);
                $scope.content.workingMode = false;
                $scope.successMessages.push(data["displayMessage"]);
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.content.workingMode = false;
                _.each(error.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred installing Errata: ") + errorMessage);
                });

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

        function initContentAction(content) {
            $scope.actionParams['content_type'] = content.contentType;
            $scope.actionParams['content'] = content.content.split(/ *, */);
            $scope.actionParams['ids'] = $scope.getSelectedSystemIds();
        }

    }]
);
