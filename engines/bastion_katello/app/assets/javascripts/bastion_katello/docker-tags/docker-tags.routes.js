/**
 Copyright 2015 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc object
 * @name Bastion.docker-tags.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the docker tags module.
 */
angular.module('Bastion.docker-tags').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('docker-tags', {
        abstract: true,
        controller: 'DockerTagsController',
        templateUrl: 'docker-tags/views/docker-tags.html'
    })
    .state('docker-tags.index', {
        url: '/docker_tags',
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'docker-tags/views/docker-tags-table-full.html'
            }
        }
    })
    .state('docker-tags.details', {
        url: '/docker_tags/:tagId',
        permission: ['view_products', 'view_content_views'],
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'docker-tags/views/docker-tags-table-collapsed.html'
            },
            'action-panel': {
                controller: 'DockerTagsDetailsController',
                templateUrl: 'docker-tags/details/views/docker-tags-details.html'
            }
        }
    });
}]);
