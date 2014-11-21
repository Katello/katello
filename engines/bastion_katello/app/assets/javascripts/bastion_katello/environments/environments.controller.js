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
 * @name  Bastion.environments.controller:EnvironmentsController
 *
 * @requires $scope
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the environments path page.
 */
angular.module('Bastion.environments').controller('EnvironmentsController',
    ['$scope', 'Organization', 'CurrentOrganization',
        function ($scope, Organization, CurrentOrganization) {

            Organization.paths({id: CurrentOrganization}, function (paths) {
                var actualPaths = [];

                $scope.library = paths[0].environments[0];

                angular.forEach(paths, function (path, index) {
                    paths[index].environments.splice(0, 1);

                    if (paths[index].environments.length !== 0) {
                        actualPaths.push(path);
                    }
                });

                $scope.paths = actualPaths;
            });

            $scope.lastEnvironment = function (path) {
                return path.environments[path.environments.length - 1];
            };

        }]
);
