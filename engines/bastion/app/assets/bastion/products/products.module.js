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
    'ui.compat',
    'Bastion.widgets',
    'Bastion.providers',
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
angular.module('Bastion.products').config(['$stateProvider', function($stateProvider) {
    var templatePrefix = '../';

    $stateProvider.state('products', {
        abstract: true,
        controller: 'ProductsController',
        templateUrl: templatePrefix + 'products/views/products.html'
    })
    .state('products.index', {
        url: '/products',
        views: {
            'table': {
                templateUrl: templatePrefix + 'products/views/products-table-full.html'
            }
        }
    })

    .state('products.new', {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewProductController',
                templateUrl: templatePrefix + 'products/views/new.html'
            }
        }
    })
    .state('products.new.form', {
        url: '/products/new',
        collapsed: true,
        controller: 'ProductFormController',
        templateUrl: templatePrefix + 'products/views/new-form.html'
    })
    .state('products.new.provider', {
        url: '/products/new/provider',
        collapsed: true,
        controller: 'NewProviderController',
        templateUrl: templatePrefix + 'providers/views/new.html'
    })

    .state("products.discovery", {
        collapsed: true,
        abstract: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                templateUrl: templatePrefix + 'products/views/discovery_base.html',
                controller: 'DiscoveryController'
            }
        }
    })
    .state("products.discovery.scan", {
        collapsed: true,
        url: '/products/discovery/scan',
        templateUrl: templatePrefix + 'products/views/discovery.html'

    })
    .state("products.discovery.create", {
        collapsed: true,
        url: '/products/discovery/scan/create',
        templateUrl: templatePrefix + 'products/views/discovery_create.html',
        controller: 'DiscoveryFormController'

    })

    .state("products.details", {
        abstract: true,
        url: '/products/:productId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'products/views/products-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ProductDetailsController',
                templateUrl: templatePrefix + 'products/views/product-details.html'
            }
        }
    })
    .state('products.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'ProductDetailsInfoController',
        templateUrl: templatePrefix + 'products/views/product-info.html'
    })

    .state('products.details.repositories', {
        abstract: true,
        controller: 'ProductRepositoriesController',
        template: '<div ui-view></div>'
    })
    .state('products.details.repositories.index', {
        collapsed: true,
        url: '/repositories',
        templateUrl: templatePrefix + 'products/views/product-repositories.html'
    })
    .state('products.details.repositories.new', {
        url: '/repositories/new',
        collapsed: true,
        controller: 'NewRepositoryController',
        templateUrl: templatePrefix + 'repositories/views/new.html'
    })
    .state('products.details.repositories.info', {
        url: '/repositories/:repositoryId',
        collapsed: true,
        controller: 'RepositoryDetailsInfoController',
        templateUrl: templatePrefix + 'repositories/views/repository-info.html'
    });

}]);
