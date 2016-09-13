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
        abstract: true,
        controller: 'OstreeBranchesController',
        templateUrl: 'ostree-branches/views/ostree-branches.html'
    })
    .state('ostree-branches.index', {
        url: '/ostree_branches?repositoryId',
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'ostree-branches/views/ostree-branches-table-full.html'
            }
        }
    })
    .state('ostree-branches.details', {
        abstract: true,
        url: '/ostree_branches/:branchId',
        permission: ['view_products', 'view_content_views'],
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'ostree-branches/views/ostree-branches-table-collapsed.html'
            },
            'action-panel': {
                controller: 'OstreeBranchesDetailsController',
                templateUrl: 'ostree-branches/details/views/ostree-branches-details.html'
            }
        }
    })
    .state('ostree-branches.details.info', {
        url: '/ostree_branches/info',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'ostree-branches/details/views/ostree-branches-details-info.html'
    })
    .state('ostree-branches.details.repositories', {
        url: '/ostree_branches/repositories',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'OstreeBranchesDetailsRepositoriesController',
        templateUrl: 'ostree-branches/details/views/ostree-branches-details-repositories.html'
    });
}]);
