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
            label: "{{ 'Container Image Tags' | translate }}"
        }
    })
    .state('docker-tag', {
        abstract: true,
        url: '/docker_tags/:tagId',
        permission: 'view_products',
        controller: 'DockerTagDetailsController',
        templateUrl: 'docker-tags/details/views/docker-tag-details.html',
        ncyBreadcrumb: {
            label: "{{ 'Container Image Tags' | translate }}",
            parent: 'docker-tags'
        }
    })
    .state('docker-tag.info', {
        url: '',
        permission: 'view_products',
        templateUrl: 'docker-tags/details/views/docker-tag-info.html',
        ncyBreadcrumb: {
            label: "{{ tag.name }}",
            parent: 'docker-tag'
        }
    })
    .state('docker-tag.environments', {
        url: '/environments',
        permission: 'view_environments',
        templateUrl: 'docker-tags/details/views/docker-tag-environments.html',
        controller: 'DockerTagEnvironmentsController',
        ncyBreadcrumb: {
            label: "{{ 'Lifecycle Environments' | translate }}",
            parent: 'docker-tag.info'
        }
    });
}]);
