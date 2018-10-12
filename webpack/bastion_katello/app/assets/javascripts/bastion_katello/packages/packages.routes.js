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
        permission: ['view_products', 'view_content_views'],
        views: {
            '@': {
                controller: 'PackagesController',
                templateUrl: 'packages/views/packages.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Packages' | translate }}"
        }
    })
    .state('package', {
        abstract: true,
        url: '/packages/:packageId',
        permission: ['view_products', 'view_content_views'],
        controller: 'PackageController',
        templateUrl: 'packages/details/views/package.html'
    })
    .state('package.info', {
        url: '',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/package-info.html',
        ncyBreadcrumb: {
            label: "{{ package.nvrea }}",
            parent: 'packages'
        }
    })
    .state('package.dependencies', {
        url: '/dependencies',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/package-dependencies.html',
        ncyBreadcrumb: {
            label: "{{ 'Dependencies' | translate }}",
            parent: 'package.info'
        }
    })
    .state('package.files', {
        url: '/files',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'packages/details/views/package-files.html',
        ncyBreadcrumb: {
            label: "{{ 'Files' | translate }}",
            parent: 'package.info'
        }
    })
    .state('package.repositories', {
        url: '/repositories',
        permission: ['view_products', 'view_content_views'],
        controller: 'PackageRepositoriesController',
        templateUrl: 'packages/details/views/package-repositories.html',
        ncyBreadcrumb: {
            label: "{{ 'Repositories' | translate }}",
            parent: 'package.info'
        }
    });
}]);
