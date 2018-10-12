/**
 * @ngdoc object
 * @name Bastion.sync-plans.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for sync plan level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.sync-plans').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('sync-plans', {
        url: '/sync_plans',
        permission: 'view_sync_plans',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'SyncPlansController',
                templateUrl: 'sync-plans/views/sync-plans.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Sync Plans' | translate }}"
        }
    });

    $stateProvider.state('sync-plans.new', {
        url: '/sync_plans/new',
        permission: 'create_sync_plans',
        views: {
            '@': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/new/views/new-sync-plan.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'New Sync Plan' | translate }}"
        }
    });

    $stateProvider.state("sync-plan", {
        abstract: true,
        url: '/sync_plans/:syncPlanId',
        permission: 'view_sync_plans',
        controller: 'SyncPlanDetailsController',
        templateUrl: 'sync-plans/details/views/sync-plan-details.html'
    })
    .state('sync-plan.info', {
        url: '',
        permission: 'view_sync_plans',
        controller: 'SyncPlanDetailsInfoController',
        templateUrl: 'sync-plans/details/views/sync-plan-info.html',
        ncyBreadcrumb: {
            label: "{{ syncPlan.name }}",
            parent: 'sync-plans'
        }
    })

    .state('sync-plan.products', {
        abstract: true,
        url: '/products',
        permission: 'view_sync_plans',
        template: '<div ui-view></div>'
    })
    .state('sync-plan.products.list', {
        url: '',
        permission: 'view_sync_plans',
        controller: 'SyncPlanProductsController',
        templateUrl: 'sync-plans/details/views/sync-plan-products.html',
        ncyBreadcrumb: {
            label: "{{ 'List Products' | translate }}",
            parent: 'sync-plan.info'
        }
    })
    .state('sync-plan.products.add', {
        url: '/add',
        permission: 'edit_sync_plans',
        controller: 'SyncPlanAddProductsController',
        templateUrl: 'sync-plans/details/views/sync-plan-products.html',
        ncyBreadcrumb: {
            label: "{{ 'Add Products' | translate }}",
            parent: 'sync-plan.info'
        }
    });
}]);
