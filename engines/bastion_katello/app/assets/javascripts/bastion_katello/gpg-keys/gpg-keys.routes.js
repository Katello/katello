/**
 * @ngdoc object
 * @name Bastion.gpg-keys.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.gpg-keys').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('gpg-keys', {
        url: '/gpg_keys',
        permission: 'view_gpg_keys',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'GPGKeysController',
                templateUrl: 'gpg-keys/views/gpg-keys.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'GPG Keys' | translate}}"
        }
    })
    .state('gpg-keys.new', {
        url: '/new',
        permission: 'create_gpg_keys',
        views: {
            '@': {
                controller: 'NewGPGKeyController',
                templateUrl: 'gpg-keys/new/views/new-gpg-key.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{'New GPG Key' | translate }}",
            parent: 'gpg-keys'
        }
    })
    .state("gpg-key", {
        abstract: true,
        url: '/gpg_keys/:gpgKeyId',
        permission: 'view_gpg_keys',
        controller: 'GPGKeyDetailsController',
        templateUrl: 'gpg-keys/details/views/gpg-key-details.html'
    })
    .state('gpg-key.info', {
        url: '',
        permission: 'view_gpg_keys',
        controller: 'GPGKeyDetailsInfoController',
        templateUrl: 'gpg-keys/details/views/gpg-key-info.html',
        ncyBreadcrumb: {
            label: "{{ gpgKey.name }}",
            parent: 'gpg-keys'
        }
    })
    .state('gpg-key.products', {
        url: '/products',
        permission: 'view_gpg_keys',
        controller: 'GPGKeyProductsController',
        templateUrl: 'gpg-keys/details/views/gpg-key-products.html',
        ncyBreadcrumb: {
            label: "{{ 'Products' | translate }}",
            parent: 'gpg-key.info'
        }
    })
    .state('gpg-key.repositories', {
        url: '/repositories',
        permission: 'view_gpg_keys',
        controller: 'GPGKeyRepositoriesController',
        templateUrl: 'gpg-keys/details/views/gpg-key-repositories.html',
        ncyBreadcrumb: {
            label: "{{ 'Repositories' | translate }}",
            parent: 'gpg-key.info'
        }
    });
}]);
