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
 * @name  Bastion.content-views.controller:ContentViewPromotionController
 *
 * @requires $scope
 * @requires ContentView
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPromotionController',
    ['$scope', 'ContentView', 'CurrentOrganization', '$http',
    function ($scope, ContentView, CurrentOrganization, $http) {

        $scope.promotion = {};

        $http.get('/katello/organizations/' + CurrentOrganization + '/environments/registerable_paths')
            .success(function (paths) {

                angular.forEach($scope.version.environments, function (environment) {
                    angular.forEach(paths, function (path) {
                        angular.forEach(path, function (item, index) {
                            if (environment.id.toString() === item.id.toString()) {
                                if (index + 1 < path.length) {
                                    path[index + 1].selectable = true;
                                }
                            }
                        });
                    });
                });

                $scope.availableEnvironments =  paths;
            });

        $scope.contentView.$version($scope.$stateParams.versionId, function (version) {
            $scope.version = version;
        });

        $scope.promote = function () {
            angular.forEach($scope.availableEnvironments, function (path) {
                if (path.selectable) {
                    $scope.contentView.version.environments.push(path);
                }
            });

            $scope.transitionTo('content-views-details.versions', {contentViewId: $scope.contentView.id});
        };
    }]
);
