/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc module
 * @name  Bastion.products
 *
 * @description
 *   Module for product related functionality.
 */
angular.module('Bastion.products', [
    'ngResource',
    'alchemy',
    'alch-templates',
    'ui.router',
    'Bastion.widgets',
    'Bastion.providers',
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
        collapsed: true,
        controller: 'ProductFormController',
        templateUrl: 'products/new/views/product-new-form.html'
    })
    .state('products.new.provider', {
        url: '/products/new/provider',
        collapsed: true,
        controller: 'NewProviderController',
        templateUrl: 'providers/new/views/provider-new.html'
    })
    .state('products.new.sync-plan', {
        url: '/products/new/sync-plan',
        collapsed: true,
        controller: 'NewSyncPlanController',
        templateUrl: 'sync-plans/views/new-sync-plan.html'
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
        templateUrl: 'products/discovery/views/discovery.html'

    })
    .state("products.discovery.create", {
        collapsed: true,
        url: '/products/discovery/scan/create',
        templateUrl: 'products/discovery/views/discovery-create.html',
        controller: 'DiscoveryFormController'

    })

    .state("products.details", {
        abstract: true,
        url: '/products/:productId',
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
        collapsed: true,
        controller: 'ProductDetailsInfoController',
        templateUrl: 'products/details/views/product-info.html'
    })
    .state('products.details.info.new-sync-plan', {
        url: '/sync-plan/new',
        collapsed: true,
        views: {
            '@products.details': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/views/new-sync-plan.html'
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
        templateUrl: 'products/details/views/product-repositories.html'
    })
    .state('products.details.repositories.new', {
        url: '/repositories/new',
        collapsed: true,
        controller: 'NewRepositoryController',
        templateUrl: 'repositories/new/views/repository-new.html'
    })
    .state('products.details.repositories.info', {
        url: '/repositories/:repositoryId',
        collapsed: true,
        controller: 'RepositoryDetailsInfoController',
        templateUrl: 'repositories/details/views/repository-info.html'
    });

    $stateProvider.state('products.details.tasks', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('products.details.tasks.index', {
        url: '/tasks',
        collapsed: true,
        templateUrl: 'products/details/views/product-tasks.html'
    })
    .state('products.details.tasks.details', {
        url: '/tasks/:taskId',
        collapsed: true,
        data: { defaultBackState: 'products.details.tasks.index' },
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
        collapsed: true,
        controller: 'ProductsBulkActionSyncController',
        templateUrl: 'products/bulk/views/bulk-actions-sync.html'
    })
    .state('products.bulk-actions.sync-plan', {
        url: '/products/bulk-actions/sync-plan',
        collapsed: true,
        controller: 'ProductsBulkActionSyncPlanController',
        templateUrl: 'products/bulk/views/bulk-actions-sync-plan.html'
    })
    .state('products.bulk-actions.sync-plan.new', {
        url: '/products/bulk-actions/sync-plan/new',
        collapsed: true,
        views: {
            '@products.bulk-actions': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/views/new-sync-plan.html'
            }
        }
    });
}]);
