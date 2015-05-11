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
