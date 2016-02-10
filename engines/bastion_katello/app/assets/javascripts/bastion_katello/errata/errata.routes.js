/**
 * @ngdoc object
 * @name Bastion.errata.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the errata module.
 */
angular.module('Bastion.errata').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('errata', {
        url: '/errata',
        abstract: true,
        controller: 'ErrataController',
        templateUrl: 'errata/views/errata.html'
    })
    .state('errata.index', {
        url: '?repositoryId',
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-full.html'
            }
        }
    })

    .state('errata.apply', {
        url: '/errata/apply',
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-collapsed.html'
            },
            'action-panel': {
                templateUrl: 'errata/views/apply-errata.html'
            }
        }
    })
    .state('errata.apply.select-content-hosts', {
        url: '/select-content-hosts',
        collapsed: true,
        permission: 'edit_hosts',
        controller: 'ErrataContentHostsController',
        templateUrl: 'errata/views/apply-errata-select-content-hosts.html'
    })
    .state('errata.apply.confirm', {
        url: '/confirm',
        collapsed: true,
        permission: 'edit_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html'
    })

    .state('errata.details', {
        abstract: true,
        url: '/:errataId',
        permission: ['view_products', 'view_content_views'],
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ErrataDetailsController',
                templateUrl: 'errata/details/views/errata-details.html'
            }
        }
    })
    .state('errata.details.apply', {
        url: '/apply',
        collapsed: true,
        permission: 'edit_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html'
    })
    .state('errata.details.info', {
        url: '/info',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'errata/details/views/errata-details-info.html'
    })
    .state('errata.details.content-hosts', {
        url: '/content-hosts',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'ErrataContentHostsController',
        templateUrl: 'errata/details/views/errata-details-content-hosts.html'
    })
    .state('errata.details.repositories', {
        url: '/repositories',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'ErrataDetailsRepositoriesController',
        templateUrl: 'errata/details/views/errata-details-repositories.html'
    })
    .state('errata.details.task-details', {
        url: '/tasks/:taskId',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'TaskDetailsController',
        templateUrl: 'errata/views/errata-task-details.html'
    })

    .state('errata.tasks', {
        abstract: true,
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-collapsed.html'
            },
            'action-panel': {
                templateUrl: 'errata/views/errata-tasks.html'
            }
        }
    })
    .state('errata.tasks.index', {
        url: '/tasks',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'errata/views/errata-tasks-list.html'
    })
    .state('errata.tasks.details', {
        url: '/tasks/:taskId',
        collapsed: true,
        permission: ['view_products', 'view_content_views'],
        controller: 'TaskDetailsController',
        templateUrl: 'errata/views/errata-task-details.html'
    });
}]);
