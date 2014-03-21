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
 * @name  Bastion.systems.controller:SystemsBulkActionEnvironmentController
 *
 * @requires $scope
 * @requires SystemBulkAction
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *   A controller for providing bulk action functionality for setting content view and environment
 */
angular.module('Bastion.systems').controller('SystemsBulkActionEnvironmentController',
    ['$scope', 'SystemBulkAction', 'Organization', 'CurrentOrganization', 'ContentView',
    function ($scope, SystemBulkAction, Organization, CurrentOrganization, ContentView) {

        $scope.setState(false, [], []);
        $scope.selected = {
            environment: undefined,
            contentView: undefined
        };

        $scope.environments = Organization.registerableEnvironments({organizationId: CurrentOrganization});

        $scope.$watch('selected.environment', function (environment) {
            if (environment) {
                $scope.fetchViews();
            }
        });

        $scope.fetchViews = function () {
            $scope.fetchingContentViews = true;

            ContentView.query({ 'environment_id': $scope.selected.environment.id }, function (response) {
                $scope.contentViews = response.results;
                $scope.fetchingContentViews = false;
            });
        };

        $scope.performAction = function () {
            $scope.setState(true, [], []);

            SystemBulkAction.environmentContentView(actionParams(), function (response) {
                $scope.setState(false, response.displayMessages, []);
            }, function (data) {
                $scope.setState(false, [], data.errors);
            });
        };

        function actionParams() {
            var params = $scope.nutupane.getAllSelectedResults();
            params['organization_id'] = CurrentOrganization;
            params['environment_id'] = $scope.selected.environment.id;
            params['content_view_id'] = $scope.selected.contentView.id;
            return params;
        }
    }]
);
