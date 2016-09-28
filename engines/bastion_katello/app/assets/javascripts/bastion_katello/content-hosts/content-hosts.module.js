/**
 * @ngdoc module
 * @name  Bastion.content-hosts
 *
 * @description
 *   Module for content hosts related functionality.
 */
angular.module('Bastion.content-hosts', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.i18n',
    'Bastion.common',
    'Bastion.components',
    'Bastion.components.formatters',
    'Bastion.organizations',
    'Bastion.subscriptions',
    'Bastion.capsules',
    'Bastion.hosts',
    'Bastion.errata',
    'Bastion.host-collections'
]);

/**
 * @ngdoc object
 * @name Bastion.content-hosts.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for content hosts level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.content-hosts').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('content-hosts', {
        abstract: true,
        controller: 'ContentHostsController',
        templateUrl: 'content-hosts/views/content-hosts.html'
    });

    $stateProvider.state('content-hosts.index', {
        url: '/content_hosts',
        permission: 'view_hosts',
        views: {
            'table': {
                templateUrl: 'content-hosts/views/content-hosts-table-full.html'
            }
        }
    });

    $stateProvider.state('content-hosts.register', {
        url: '/content_hosts/register',
        permission: 'view_hosts',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'content-hosts/views/content-hosts-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ContentHostRegisterController',
                templateUrl: 'content-hosts/views/register.html'
            }
        }
    });

    $stateProvider.state("content-hosts.details", {
        abstract: true,
        url: '/content_hosts/:hostId',
        permission: 'view_hosts',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'content-hosts/views/content-hosts-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ContentHostDetailsController',
                templateUrl: 'content-hosts/details/views/content-host-details.html'
            }
        }
    })
    .state('content-hosts.details.info', {
        url: '/info',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'ContentHostDetailsInfoController',
        templateUrl: 'content-hosts/details/views/content-host-info.html'
    })
    .state('content-hosts.details.provisioning', {
        url: '/provisioning',
        permission: 'view_hosts',
        collapsed: true,
        templateUrl: 'content-hosts/details/views/content-host-provisioning-info.html'
    })
    .state('content-hosts.details.products', {
        url: '/products',
        permission: 'view_products',
        collapsed: true,
        controller: 'ContentHostProductsController',
        templateUrl: 'content-hosts/details/views/content-host-products.html'
    });

    $stateProvider.state('content-hosts.details.events', {
        collapsed: true,
        url: '/events',
        permission: 'view_hosts',
        controller: 'ContentHostEventsController',
        templateUrl: 'content-hosts/details/views/content-host-events.html'
    });

    $stateProvider.state('content-hosts.details.tasks', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-hosts.details.tasks.index', {
        url: '/tasks',
        permission: 'view_hosts',
        collapsed: true,
        templateUrl: 'content-hosts/details/views/content-host-tasks.html'
    })
    .state('content-hosts.details.tasks.details', {
        url: '/tasks/:taskId',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html'
    });

    $stateProvider.state('content-hosts.details.subscriptions', {
        abstract: true,
        collapsed: true,
        controller: 'ContentHostBaseSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-subscriptions.html'
    })
    .state('content-hosts.details.subscriptions.list', {
        url: '/subscriptions',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'ContentHostSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-subscriptions-list.html'
    })
    .state('content-hosts.details.subscriptions.add', {
        url: '/add-subscriptions',
        permission: 'attach_subscriptions',
        collapsed: true,
        controller: 'ContentHostAddSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-add-subscriptions.html'
    });

    $stateProvider.state('content-hosts.details.host-collections', {
        abstract: true,
        collapsed: true,
        templateUrl: 'content-hosts/details/views/host-collections.html'
    })
    .state('content-hosts.details.host-collections.list', {
        url: '/host-collections',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'ContentHostHostCollectionsController',
        templateUrl: 'content-hosts/details/views/host-collections-table.html'
    })
    .state('content-hosts.details.host-collections.add', {
        url: '/host-collections/add',
        permission: 'edit_hosts',
        collapsed: true,
        controller: 'ContentHostAddHostCollectionsController',
        templateUrl: 'content-hosts/details/views/host-collections-table.html'
    });

    $stateProvider.state("content-hosts.bulk-actions", {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'content-hosts/views/content-hosts-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ContentHostsBulkActionController',
                templateUrl: 'content-hosts/bulk/views/bulk-actions.html'
            }
        }
    })
    .state('content-hosts.bulk-actions.task-details', {
        url: '/content_hosts/bulk-actions/bulk-tasks/:taskId',
        collapsed: true,
        permission: ['view_hosts'],
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html'
    })
    .state('content-hosts.bulk-actions.packages', {
        url: '/content_hosts/bulk-actions/packages',
        permission: 'edit_hosts',
        collapsed: true,
        controller: 'ContentHostsBulkActionPackagesController',
        templateUrl: 'content-hosts/bulk/views/bulk-actions-packages.html'
    })
    .state('content-hosts.bulk-actions.errata', {
        abstract: true,
        collapsed: true,
        controller: 'ContentHostsBulkActionErrataController',
        template: '<div ui-view></div>'
    })
    .state('content-hosts.bulk-actions.errata.list', {
        collapsed: true,
        url: '/content_hosts/bulk-actions/errata',
        permission: 'edit_hosts',
        templateUrl: 'content-hosts/bulk/views/bulk-actions-errata.html'
    })
    .state('content-hosts.bulk-actions.errata.details', {
        collapsed: true,
        url: '/content_hosts/bulk-actions/errata/:errataId',
        permission: 'edit_hosts',
        templateUrl: 'content-hosts/bulk/views/errata-details.html'
    })
    .state('content-hosts.bulk-actions.errata.content-hosts', {
        collapsed: true,
        url: '/content_hosts/bulk-actions/errata/:errataId/content-hosts',
        permission: 'edit_hosts',
        templateUrl: 'content-hosts/bulk/views/errata-content-hosts.html'
    })
    .state('content-hosts.bulk-actions.host-collections', {
        url: '/content_hosts/bulk-actions/bulk-host-collections',
        permission: 'edit_hosts',
        collapsed: true,
        controller: 'ContentHostsBulkActionHostCollectionsController',
        templateUrl: 'content-hosts/bulk/views/bulk-actions-host-collections.html'
    })
    .state('content-hosts.bulk-actions.subscriptions', {
        url: '/content_hosts/bulk-actions/bulk-subscriptions',
        permission: 'attach_subscriptions',
        collapsed: true,
        controller: 'ContentHostsBulkActionSubscriptionsController',
        templateUrl: 'content-hosts/bulk/views/bulk-actions-subscriptions.html'
    })
    .state('content-hosts.bulk-actions.environment', {
        url: '/content_hosts/bulk-actions/bulk-environment',
        permission: 'edit_hosts',
        collapsed: true,
        controller: 'ContentHostsBulkActionEnvironmentController',
        templateUrl: 'content-hosts/bulk/views/bulk-actions-environment.html'
    });

    $stateProvider.state('content-hosts.details.packages', {
        controller: 'ContentHostPackagesController',
        collapsed: true,
        abstract: true,
        templateUrl: 'content-hosts/content/views/content-host-packages.html'
    })
    .state('content-hosts.details.packages.actions', {
        url: '/packages/actions',
        permission: 'edit_hosts',
        collapsed: true,
        controller: 'ContentHostPackagesActionsController',
        templateUrl: 'content-hosts/content/views/content-host-packages-actions.html'
    })
    .state('content-hosts.details.packages.installed', {
        url: '/packages/installed',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'ContentHostPackagesInstalledController',
        templateUrl: 'content-hosts/content/views/content-host-packages-installed.html'
    })
    .state('content-hosts.details.packages.applicable', {
        url: '/packages/applicable',
        permission: 'view_hosts',
        collapsed: true,
        controller: 'ContentHostPackagesApplicableController',
        templateUrl: 'content-hosts/content/views/content-host-packages-applicable.html'
    })
    .state('content-hosts.details.errata', {
        abstract: true,
        collapsed: true,
        controller: 'ContentHostErrataController',
        template: '<div ui-view></div>'
    })
    .state('content-hosts.details.errata.index', {
        url: '/errata?getSearch',
        permission: 'view_hosts',
        collapsed: true,
        templateUrl: 'content-hosts/content/views/content-host-errata.html'
    })
    .state('content-hosts.details.errata.details', {
        url: '/errata/:errataId',
        permission: 'view_hosts',
        collapsed: true,
        templateUrl: 'content-hosts/content/views/errata-details.html'
    });

}]);
