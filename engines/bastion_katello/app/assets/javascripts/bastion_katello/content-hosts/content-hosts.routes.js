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
        url: '/content_hosts',
        permission: 'view_hosts',
        views: {
            '@': {
                controller: 'ContentHostsController',
                templateUrl: 'content-hosts/views/content-hosts.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Content Hosts' | translate }}"
        }
    });

    $stateProvider.state('content-hosts.register', {
        url: '/register',
        permission: 'view_hosts',
        views: {
            '@': {
                controller: 'ContentHostRegisterController',
                templateUrl: 'content-hosts/views/register.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Register a Host' | translate }}"
        }
    });

    $stateProvider.state('content-hosts.bulk-task', {
        url: '/bulk-tasks/:taskId',
        permission: ['view_hosts'],
        views: {
            '@': {
                controller: 'TaskDetailsController',
                templateUrl: 'tasks/views/task-details.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Bulk Task' | translate }}",
            parent: 'content-hosts'
        }
    });

    $stateProvider.state("content-host", {
        abstract: true,
        url: '/content_hosts/:hostId',
        permission: 'view_hosts',
        controller: 'ContentHostDetailsController',
        templateUrl: 'content-hosts/details/views/content-host-details.html'
    })
    .state('content-host.info', {
        url: '',
        permission: 'view_hosts',
        controller: 'ContentHostDetailsInfoController',
        templateUrl: 'content-hosts/details/views/content-host-info.html',
        ncyBreadcrumb: {
            label: "{{ host.name }}",
            parent: 'content-hosts'
        }
    })
    .state('content-host.provisioning', {
        url: '/provisioning',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/details/views/content-host-provisioning-info.html',
        ncyBreadcrumb: {
            label: "{{ 'Provisioning' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.products', {
        url: '/products',
        permission: 'view_products',
        controller: 'ContentHostRepositorySetsController',
        templateUrl: 'content-hosts/details/views/content-host-repository-sets.html',
        ncyBreadcrumb: {
            label: "{{ 'Products' | translate }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.events', {
        url: '/events',
        permission: 'view_hosts',
        controller: 'ContentHostEventsController',
        templateUrl: 'content-hosts/details/views/content-host-events.html',
        ncyBreadcrumb: {
            label: "{{ 'Events' | translate }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.tasks', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-host.tasks.index', {
        url: '/tasks',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/details/views/content-host-tasks.html',
        ncyBreadcrumb: {
            label: "{{ 'Tasks' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.tasks.details', {
        url: '/tasks/:taskId',
        permission: 'view_hosts',
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html',
        ncyBreadcrumb: {
            label: "{{ task.id }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.subscriptions', {
        abstract: true,
        controller: 'ContentHostBaseSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-subscriptions.html'
    })
    .state('content-host.subscriptions.list', {
        url: '/subscriptions',
        permission: 'view_hosts',
        controller: 'ContentHostSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-subscriptions-list.html',
        ncyBreadcrumb: {
            label: "{{ 'Subscriptions' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.subscriptions.add', {
        url: '/add-subscriptions',
        permission: 'attach_subscriptions',
        controller: 'ContentHostAddSubscriptionsController',
        templateUrl: 'content-hosts/details/views/content-host-add-subscriptions.html',
        ncyBreadcrumb: {
            label: "{{ 'Add Subscriptipons' | translate }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.host-collections', {
        abstract: true,
        templateUrl: 'content-hosts/details/views/content-host-host-collections.html'
    })
    .state('content-host.host-collections.list', {
        url: '/host-collections',
        permission: 'view_hosts',
        controller: 'ContentHostHostCollectionsController',
        templateUrl: 'content-hosts/details/views/content-host-host-collections-table.html',
        ncyBreadcrumb: {
            label: "{{ 'Host Collections' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.host-collections.add', {
        url: '/host-collections/add',
        permission: 'edit_hosts',
        controller: 'ContentHostAddHostCollectionsController',
        templateUrl: 'content-hosts/details/views/content-host-host-collections-table.html',
        ncyBreadcrumb: {
            label: "{{ 'Add Host Collections' | translate }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.debs', {
        controller: 'ContentHostDebsController',
        abstract: true,
        templateUrl: 'content-hosts/content/views/content-host-debs.html'
    })
    .state('content-host.debs.actions', {
        url: '/debs/actions',
        permission: 'edit_hosts',
        controller: 'ContentHostDebsActionsController',
        templateUrl: 'content-hosts/content/views/content-host-debs-actions.html',
        ncyBreadcrumb: {
            label: "{{ 'Deb Package Actions' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.debs.installed', {
        url: '/debs/installed',
        permission: 'view_hosts',
        controller: 'ContentHostDebsInstalledController',
        templateUrl: 'content-hosts/content/views/content-host-debs-installed.html',
        ncyBreadcrumb: {
            label: "{{ 'Installed Deb Packages' | translate }}",
            parent: 'content-host.info'
        }
    });

    $stateProvider.state('content-host.packages', {
        controller: 'ContentHostPackagesController',
        abstract: true,
        templateUrl: 'content-hosts/content/views/content-host-packages.html'
    })
    .state('content-host.packages.actions', {
        url: '/packages/actions',
        permission: 'edit_hosts',
        controller: 'ContentHostPackagesActionsController',
        templateUrl: 'content-hosts/content/views/content-host-packages-actions.html',
        ncyBreadcrumb: {
            label: "{{ 'Package Actions' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.packages.installed', {
        url: '/packages/installed',
        permission: 'view_hosts',
        controller: 'ContentHostPackagesInstalledController',
        templateUrl: 'content-hosts/content/views/content-host-packages-installed.html',
        ncyBreadcrumb: {
            label: "{{ 'Installed Packages' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.packages.applicable', {
        url: '/packages/applicable',
        permission: 'view_hosts',
        controller: 'ContentHostPackagesApplicableController',
        templateUrl: 'content-hosts/content/views/content-host-packages-applicable.html',
        ncyBreadcrumb: {
            label: "{{ 'Applicable Packages' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.errata', {
        abstract: true,
        controller: 'ContentHostErrataController',
        template: '<div ui-view></div>'
    })
    .state('content-host.errata.index', {
        url: '/errata?getSearch',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/content/views/content-host-errata.html',
        ncyBreadcrumb: {
            label: "{{ 'Errata' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.errata.details', {
        url: '/errata/:errataId',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/content/views/errata-details.html',
        ncyBreadcrumb: {
            label: "{{ erratum.errata_id  }}",
            parent: 'content-host.errata.index'
        }
    })
    .state('content-host.traces', {
        abstract: true,
        collapsed: true,
        controller: 'ContentHostTracesController',
        template: '<div ui-view></div>'
    })
    .state('content-host.traces.index', {
        url: '/traces',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/content/views/content-host-traces.html',
        ncyBreadcrumb: {
            label: "{{ 'Traces' | translate }}",
            parent: 'content-host.info'
        }
    })
    .state('content-host.module-streams', {
        abstract: true,
        controller: 'ContentHostModuleStreamsController',
        template: '<div ui-view></div>'
    })
    .state('content-host.module-streams.index', {
        url: '/module-streams',
        permission: 'view_hosts',
        templateUrl: 'content-hosts/content/views/content-host-module-streams.html',
        ncyBreadcrumb: {
            label: "{{ 'Module Streams' | translate }}",
            parent: 'content-host.info'
        }
    });
}]);
