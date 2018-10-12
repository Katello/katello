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
        url: '/products',
        permission: 'view_products',
        views: {
            '@': {
                controller: 'ProductsController',
                templateUrl: 'products/views/products.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Products' | translate }}"
        }
    });

    $stateProvider.state('products.new', {
        abstract: true,
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'NewProductController',
                templateUrl: 'products/new/views/product-new.html'
            }
        }
    })
    .state('products.new.form', {
        url: '/new',
        permission: 'create_products',
        controller: 'ProductFormController',
        templateUrl: 'products/new/views/product-new-form.html',
        ncyBreadcrumb: {
            label: "{{ 'New Product' | translate }}"
        }
    });

    $stateProvider.state("product-discovery", {
        abstract: true,
        url: '/products/discovery',
        controller: 'DiscoveryController',
        templateUrl: 'products/discovery/views/discovery-base.html'
    })
    .state("product-discovery.scan", {
        url: '/scan',
        permission: 'edit_products',
        templateUrl: 'products/discovery/views/discovery.html',
        ncyBreadcrumb: {
            label: "{{ 'Discover Repositories' | translate }}",
            parent: 'products'
        }
    })
    .state("product-discovery.create", {
        url: '/scan/create',
        permission: 'edit_products',
        templateUrl: 'products/discovery/views/discovery-create.html',
        controller: 'DiscoveryCreateController',
        ncyBreadcrumb: {
            label: "{{ 'Create Repositories' | translate }}",
            parent: 'product-discovery.scan'
        }
    });

    $stateProvider.state("product", {
        abstract: true,
        url: '/products/:productId',
        permission: 'view_products',
        controller: 'ProductDetailsController',
        templateUrl: 'products/details/views/product-details.html'
    })
    .state('product.info', {
        url: '',
        permission: 'view_products',
        controller: 'ProductDetailsInfoController',
        templateUrl: 'products/details/views/product-info.html',
        ncyBreadcrumb: {
            label: "{{ product.name }}",
            parent: 'products'
        }
    });

    $stateProvider.state('product.tasks', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('product.tasks.index', {
        url: '/tasks',
        permission: 'view_products',
        templateUrl: 'products/details/views/product-tasks.html',
        ncyBreadcrumb: {
            label: "{{'Tasks' | translate }}",
            parent: 'product.info'
        }
    })
    .state('product.tasks.details', {
        url: '/tasks/:taskId',
        permission: 'view_products',
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html',
        ncyBreadcrumb: {
            label: "{{ task.id }}",
            parent: 'product.tasks.index'
        }
    });
}]);
