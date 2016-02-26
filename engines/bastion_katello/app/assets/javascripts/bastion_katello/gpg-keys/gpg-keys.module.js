/**
 * @ngdoc module
 * @name  Bastion.gpg-keys
 *
 * @description
 *   Module for GPG key related functionality.
 */
angular.module('Bastion.gpg-keys', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.common',
    'Bastion.components',
    'ngUpload'
]);

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
    $stateProvider.state('gpgKeys', {
        abstract: true,
        controller: 'GPGKeysController',
        templateUrl: 'gpg-keys/views/gpg-keys.html'
    })
    .state('gpgKeys.index', {
        url: '/gpg_keys',
        permission: 'view_gpg_keys',
        views: {
            'table': {
                templateUrl: 'gpg-keys/views/gpg-keys-table-full.html'
            }
        }
    })
    .state('gpgKeys.new', {
        url: '/gpg_keys/new',
        permission: 'create_gpg_keys',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'gpg-keys/views/gpg-keys-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewGPGKeyController',
                templateUrl: 'gpg-keys/new/views/gpg-key-new.html'
            }
        }
    })
    .state("gpgKeys.details", {
        abstract: true,
        url: '/gpg_keys/:gpgKeyId',
        permission: 'view_gpg_keys',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'gpg-keys/views/gpg-keys-table-collapsed.html'
            },
            'action-panel': {
                controller: 'GPGKeyDetailsController',
                templateUrl: 'gpg-keys/details/views/gpg-key-details.html'
            }
        }
    })
    .state('gpgKeys.details.info', {
        url: '/info',
        permission: 'view_gpg_keys',
        collapsed: true,
        controller: 'GPGKeyDetailsInfoController',
        templateUrl: 'gpg-keys/details/views/gpg-key-info.html'
    })
    .state('gpgKeys.details.products', {
        url: '/products',
        permission: 'view_gpg_keys',
        collapsed: true,
        controller: 'GPGKeyDetailsController',
        templateUrl: 'gpg-keys/details/views/gpg-key-products.html'
    })
    .state('gpgKeys.details.repositories', {
        url: '/repositories',
        permission: 'view_gpg_keys',
        collapsed: true,
        controller: 'GPGKeyDetailsController',
        templateUrl: 'gpg-keys/details/views/gpg-key-repositories.html'
    });
}]);
