/**
 * @ngdoc module
 * @name  Bastion.products
 *
 * @description
 *   Module for product related functionality.
 */
angular.module('Bastion.products', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.utils',
    'Bastion.components',
    'Bastion.sync-plans',
    'Bastion.gpg-keys',
    'Bastion.tasks'
]);

/**
 * @ngdoc object
 * @name Bastion.products.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.products').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('products', {
        abstract: true,
        controller: 'ProductsController',
        templateUrl: 'products/views/products.html'
    })
    .state('products.index', {
        url: '/products',
        permission: 'view_products',
        views: {
            'table': {
                templateUrl: 'products/views/products-table-full.html'
            }
        }
    })

    .state('products.new', {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewProductController',
                templateUrl: 'products/new/views/product-new.html'
            }
        }
    })
    .state('products.new.form', {
        url: '/products/new',
        permission: 'create_products',
        collapsed: true,
        controller: 'ProductFormController',
        templateUrl: 'products/new/views/product-new-form.html'
    })
    .state('products.new.sync-plan', {
        url: '/products/new/sync-plan',
        permission: 'create_sync_plans',
        collapsed: true,
        controller: 'NewSyncPlanController',
        templateUrl: 'sync-plans/new/views/new-sync-plan-form.html'
    })

    .state("products.discovery", {
        collapsed: true,
        abstract: true,
        views: {
            'table': {
                templateUrl: 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                templateUrl: 'products/discovery/views/discovery-base.html',
                controller: 'DiscoveryController'
            }
        }
    })
    .state("products.discovery.scan", {
        collapsed: true,
        url: '/products/discovery/scan',
        permission: 'edit_products',
        templateUrl: 'products/discovery/views/discovery.html'

    })
    .state("products.discovery.create", {
        collapsed: true,
        url: '/products/discovery/scan/create',
        permission: 'edit_products',
        templateUrl: 'products/discovery/views/discovery-create.html',
        controller: 'DiscoveryFormController'

    })

    .state("products.details", {
        abstract: true,
        url: '/products/:productId',
        permission: 'view_products',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ProductDetailsController',
                templateUrl: 'products/details/views/product-details.html'
            }
        }
    })
    .state('products.details.info', {
        url: '/info',
        permission: 'view_products',
        collapsed: true,
        controller: 'ProductDetailsInfoController',
        templateUrl: 'products/details/views/product-info.html'
    })
    .state('products.details.info.new-sync-plan', {
        url: '/sync-plan/new',
        permission: 'create_sync_plans',
        collapsed: true,
        views: {
            '@products.details': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/new/views/new-sync-plan-form.html'
            }
        }
    })

    .state('products.details.repositories', {
        abstract: true,
        controller: 'ProductRepositoriesController',
        template: '<div ui-view></div>'
    })
    .state('products.details.repositories.index', {
        collapsed: true,
        url: '/repositories',
        permission: 'view_products',
        templateUrl: 'products/details/views/product-repositories.html'
    })
    .state('products.details.repositories.new', {
        url: '/repositories/new',
        permission: 'create_products',
        collapsed: true,
        controller: 'NewRepositoryController',
        templateUrl: 'repositories/new/views/repository-new.html'
    })
    .state('products.details.repositories.info', {
        url: '/repositories/:repositoryId',
        permission: 'view_products',
        collapsed: true,
        controller: 'RepositoryDetailsInfoController',
        templateUrl: 'repositories/details/views/repository-info.html'
    })
    .state('products.details.repositories.manage-content', {
        abstract: true,
        controller: 'RepositoryManageContentController',
        template: '<div ui-view></div>'
    })
    .state('products.details.repositories.manage-content.packages', {
        url: '/repositories/:repositoryId/content/packages',
        permission: 'view_products',
        collapsed: true,
        templateUrl: 'repositories/details/views/repository-manage-packages.html'
    })
    .state('products.details.repositories.manage-content.package-groups', {
        url: '/repositories/:repositoryId/content/package_groups',
        permission: 'view_products',
        collapsed: true,
        templateUrl: 'repositories/details/views/repository-manage-package-groups.html'
    })
    .state('products.details.repositories.manage-content.puppet-modules', {
        url: '/repositories/:repositoryId/content/puppet_modules',
        permission: 'view_products',
        collapsed: true,
        templateUrl: 'repositories/details/views/repository-manage-puppet-modules.html'
    })
    .state('products.details.repositories.manage-content.docker-manifests', {
        url: '/repositories/:repositoryId/content/docker_manifests',
        permission: 'view_products',
        collapsed: true,
        templateUrl: 'repositories/details/views/repository-manage-docker-manifests.html'
    });

    $stateProvider.state('products.details.tasks', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('products.details.tasks.index', {
        url: '/tasks',
        permission: 'view_products',
        collapsed: true,
        templateUrl: 'products/details/views/product-tasks.html'
    })
    .state('products.details.tasks.details', {
        url: '/tasks/:taskId',
        permission: 'view_products',
        collapsed: true,
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html'
    });

    $stateProvider.state("products.bulk-actions", {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ProductsBulkActionController',
                templateUrl: 'products/bulk/views/bulk-actions.html'
            }
        }
    })
    .state('products.bulk-actions.sync', {
        url: '/products/bulk-actions/sync',
        permission: 'sync_products',
        collapsed: true,
        controller: 'ProductsBulkActionSyncController',
        templateUrl: 'products/bulk/views/bulk-actions-sync.html'
    })
    .state('products.bulk-actions.sync-plan', {
        url: '/products/bulk-actions/sync-plan',
        permission: 'edit_products',
        collapsed: true,
        controller: 'ProductsBulkActionSyncPlanController',
        templateUrl: 'products/bulk/views/bulk-actions-sync-plan.html'
    })
    .state('products.bulk-actions.sync-plan.new', {
        url: '/products/bulk-actions/sync-plan/new',
        permission: 'create_sync_plans',
        collapsed: true,
        views: {
            '@products.bulk-actions': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/new/views/new-sync-plan-form.html'
            }
        }
    });
}]);
