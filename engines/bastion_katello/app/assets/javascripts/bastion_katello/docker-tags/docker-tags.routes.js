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
        url: '/docker_tags',
        permission: ['view_products', 'view_content_views'],
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'DockerTagsController',
                templateUrl: 'docker-tags/views/docker-tags.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Docker Tags' | translate }}"
        }
    })
    .state('docker-tag', {
        url: '/docker_tags/:tagId',
        permission: ['view_products', 'view_content_views'],
        controller: 'DockerTagsDetailsController',
        templateUrl: 'docker-tags/details/views/docker-tags-details.html',
        ncyBreadcrumb: {
            label: "{{ tag.full_name }}",
            parent: 'docker-tags'
        }
    });
}]);
