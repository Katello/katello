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
        permission: ['view_products', 'view_content_views'],
        views: {
          '@': {
              controller: 'ErrataController',
              templateUrl: 'errata/views/errata.html'
          }
        },
        ncyBreadcrumb: {
            label: "{{ 'Errata' | translate }}"
        }
    });

    $stateProvider.state('errata.tasks', {
        url: '/tasks',
        abstract: true,
        permission: ['view_products', 'view_content_views'],
        views: {
            '@': {
                templateUrl: 'errata/views/errata-tasks.html'
            }
        }
    })
    .state('errata.tasks.list', {
        url: '',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'errata/views/errata-tasks-list.html',
        ncyBreadcrumb: {
            label: "{{ 'Tasks' | translate }}",
            parent: 'errata'

        }
    })
    .state('errata.tasks.task', {
        url: '/:taskId',
        permission: ['view_products', 'view_content_views'],
        controller: 'TaskDetailsController',
        templateUrl: 'errata/views/errata-task-details.html',
        ncyBreadcrumb: {
            label: '{{ task.id }}',
            parent: 'errata.tasks.list'
        }
    });

    $stateProvider.state('apply-errata', {
        url: '/errata/apply',
        abstract: true,
        templateUrl: 'errata/views/apply-errata.html'
    })
    .state('apply-errata.select-content-hosts', {
        url: '/select-content-hosts',
        permission: 'edit_hosts',
        controller: 'ErratumContentHostsController',
        templateUrl: 'errata/views/apply-errata-select-content-hosts.html',
        ncyBreadcrumb: {
            label: '{{ "Select Content Host(s)" | translate }}',
            parent: 'errata'
        }
    })
    .state('apply-errata.confirm', {
        url: '/confirm',
        permission: 'edit_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html',
        ncyBreadcrumb: {
            label: '{{ "Confirm" | translate }}',
            parent: 'apply-errata.select-content-hosts'
        }
    });

    $stateProvider.state('erratum', {
        abstract: true,
        url: '/errata/:errataId',
        permission: ['view_products', 'view_content_views'],
        controller: 'ErratumController',
        templateUrl: 'errata/details/views/erratum.html'
    })
    .state('erratum.info', {
        url: '',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'errata/details/views/erratum-info.html',
        ncyBreadcrumb: {
            label: "{{ errata.title }}",
            parent: 'errata'
        }
    })
    .state('erratum.apply', {
        url: '/apply',
        permission: 'edit_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html',
        ncyBreadcrumb: {
            label: "{{ 'Apply' | translate }}",
            parent: 'erratum.info'
        }
    })
    .state('erratum.content-hosts', {
        url: '/content-hosts',
        permission: ['view_products', 'view_content_views'],
        controller: 'ErratumContentHostsController',
        templateUrl: 'errata/details/views/erratum-content-hosts.html',
        ncyBreadcrumb: {
            label: "{{ 'Content Hosts' | translate }}",
            parent: 'erratum.info'
        }
    })
    .state('erratum.repositories', {
        url: '/repositories',
        permission: ['view_products', 'view_content_views'],
        controller: 'ErratumRepositoriesController',
        templateUrl: 'errata/details/views/erratum-repositories.html',
        ncyBreadcrumb: {
            label: "{{ 'Repositories' | translate }}",
            parent: 'erratum.info'
        }
    })
    .state('erratum.task', {
        url: '/tasks/:taskId',
        permission: ['view_products', 'view_content_views'],
        controller: 'TaskDetailsController',
        templateUrl: 'errata/views/errata-task-details.html',
        ncyBreadcrumb: {
            label: "{{ task.id }}",
            parent: 'erratum.info'
        }
    })
    .state('erratum.packages', {
        url: '/packages',
        permission: ['view_products', 'view_content_views'],
        templateUrl: 'errata/details/views/erratum-packages.html',
        ncyBreadcrumb: {
            label: "{{ 'Packages' | translate }}",
            parent: 'erratum.info'
        }
    });
}]);
