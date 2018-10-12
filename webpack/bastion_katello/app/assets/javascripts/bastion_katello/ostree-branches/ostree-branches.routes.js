/**
 * @ngdoc object
 * @name Bastion.ostree-branches.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the ostree branches module.
 */
angular.module('Bastion.ostree-branches').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('ostree-branches', {
        url: '/ostree_branches',
        permission: ['view_products', 'view_content_views'],
        views: {
            '@': {
                controller: 'OstreeBranchesController',
                templateUrl: 'ostree-branches/views/ostree-branches.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'OSTree Branches' | translate }}"
        }
    })
    .state('ostree-branch', {
        abstract: true,
        url: '/ostree_branches/:branchId',
        permission: ['view_products', 'view_content_views'],
        controller: 'OstreeBranchController',
        templateUrl: 'ostree-branches/details/views/ostree-branch.html'
    })
    .state('ostree-branch.info', {
        url: '',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'ostree-branches/details/views/ostree-branch-info.html',
        ncyBreadcrumb: {
            label: "{{ branch.name }}",
            parent: 'ostree-branches'
        }
    })
    .state('ostree-branch.repositories', {
        url: '/repositories',
        permission: ['view_products', 'view_content_views'],
        controller: 'OstreeBranchRepositoriesController',
        templateUrl: 'ostree-branches/details/views/ostree-branch-repositories.html',
        ncyBreadcrumb: {
            label: "{{ 'Repositories' | translate }}",
            parent: 'ostree-branch.info'
        }
    });
}]);
