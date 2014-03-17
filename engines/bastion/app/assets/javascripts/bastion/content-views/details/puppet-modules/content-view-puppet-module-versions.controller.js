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
 * @name  Bastion.content-views.controller:ContentViewPuppetModulesController
 *
 * @requires $scope
 * @requires gettext
 * @requires ContentView
 * @requires ContentViewPuppetModule
 *
 * @description
 *   Provides the ability to select a version of a Puppet Module for a Content View.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModuleVersionsController',
    ['$scope', 'gettext', 'ContentView', 'ContentViewPuppetModule',
    function ($scope, gettext, ContentView, ContentViewPuppetModule) {
        var success, error;

        $scope.versionsLoading = true;
        $scope.successMessages = [];
        $scope.erroressages = [];

        $scope.versions = ContentView.availablePuppetModules(
            {
                name: $scope.$stateParams.moduleName,
                id: $scope.$stateParams.contentViewId
            }, function () {
                $scope.versionsLoading = false;
            }
        );

        $scope.selectVersion = function (module) {
            var contentViewPuppetModule, contentViewPuppetModuleData = {
                contentViewId: $scope.$stateParams.contentViewId,
                uuid: module.id,
                author: module.author,
                name: module.name
            };

            if (module.useLatest) {
                contentViewPuppetModuleData.uuid = null;
            }

            contentViewPuppetModule = new ContentViewPuppetModule(contentViewPuppetModuleData);

            if ($scope.$stateParams.moduleId) {
                contentViewPuppetModule.id = $scope.$stateParams.moduleId;
                contentViewPuppetModule.$update(success, error);
            } else {
                contentViewPuppetModule.$save(success, error);
            }
        };

        success = function () {
            $scope.transitionTo('content-views.details.puppet-modules.list',
                {contentViewId: $scope.$stateParams.contentViewId});
            $scope.successMessages = [gettext('Puppet module added to Content View')];
        };

        error = function (response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages.push(gettext("An error occurred updating the Content View: ") + errorMessage);
            });
        };
    }]
);
