/**
 * @ngdoc object
 * @name Bastion.packages.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the packages module.
 */
angular.module('Bastion.packages').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('packages', {
        url: '/packages',
        abstract: true,
        controller: 'PackagesController',
        templateUrl: 'packages/views/packages.html'
    })
    .state('packages.index', {
        url: '?repositoryId',
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'packages/views/packages-table-full.html'
            }
        }
    })
    .state('packages.details', {
        abstract: true,
        url: '/:packageId',
        permission: ['view_products', 'view_content_views'],
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'packages/views/packages-table-collapsed.html'
            },
            'action-panel': {
                controller: 'PackageDetailsController',
                templateUrl: 'packages/details/views/packages-details.html'
            }
        }
    })
    .state('packages.details.info', {
        url: '/info',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/packages-details-info.html'
    })
    .state('packages.details.dependencies', {
        url: '/dependencies',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/packages-details-dependencies.html'
    })
    .state('packages.details.files', {
        url: '/files',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/packages-details-files.html'
    })
    .state('packages.details.repositories', {
        url: '/repositories',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'PackageDetailsRepositoriesController',
        templateUrl: 'packages/details/views/packages-details-repositories.html'
    });
}]);
