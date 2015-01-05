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
 * @name  Bastion.docker-tags.controller:DockerTagsDetailsController
 *
 * @requires $scope
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker tags details action pane.
 */
angular.module('Bastion.docker-tags').controller('DockerTagsDetailsController',
    ['$scope', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization',
    function ($scope, $location, Nutupane, DockerTag, CurrentOrganization) {
        if ($scope.tag) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.tag = DockerTag.get({id: $scope.$stateParams.tagId}, function () {
        });

        $scope.tag.$promise.then(function () {
            var params = {
                'organization_id':  CurrentOrganization,
                'search':           $location.search().search || "",
                'sort_by':          'name',
                'sort_order':       'ASC',
                'paged':            false,
                'ids[]':              _.pluck($scope.tag['related_tags'], 'id')
            };
            var nutupane = new Nutupane(DockerTag, params);
            $scope.table = nutupane.table;
            $scope.panel.loading = false;
            nutupane.refresh();
        });
    }
]);
