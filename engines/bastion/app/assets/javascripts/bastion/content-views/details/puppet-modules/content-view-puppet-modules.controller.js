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
 * @requires Nutupane
 * @requires ContentViewPuppetModule
 *
 * @description
 *   Provides functionality to the Content View existing Puppet Modules list.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModulesController',
    ['$scope', 'gettext', 'Nutupane', 'ContentViewPuppetModule',
    function ($scope, gettext, Nutupane, ContentViewPuppetModule) {
        var nutupane = new Nutupane(ContentViewPuppetModule, {
            contentViewId: $scope.$stateParams.contentViewId,
            'paged': true
        });

        $scope.detailsTable = nutupane.table;
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.versionText = function (module) {
            var version = gettext("Latest (Currently %s)").replace('%s', module['computed_version']);
            if (module['puppet_module']) {
                version = module['puppet_module'].version;
            }
            return version;
        };

        $scope.selectNewVersion = function (module) {
            $scope.transitionTo('content-views.details.puppet-modules.versionsForModule',
                {
                    contentViewId: $scope.$stateParams.contentViewId,
                    moduleName: module.name,
                    moduleId: module.id
                }
            );
        };

        $scope.removeModule = function (module) {
            var success, error;

            success = function () {
                $scope.successMessages = [gettext('Module %s removed from Content View.')
                    .replace('%s', module.name)];
                nutupane.removeRow(module.id);
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    $scope.errorMessages = [gettext("An error occurred updating the Content View: ") + errorMessage];
                });
            };

            ContentViewPuppetModule.remove({
                contentViewId: $scope.$stateParams.contentViewId,
                id: module.id
            }, success, error);
        };

    }]
);
