/**
 * @ngdoc object
 * @name Bastion.subscriptions.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for subscriptions level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.subscriptions').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('subscriptions', {
        url: '/subscriptions',
        permission: 'view_subscriptions',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'SubscriptionsController',
                templateUrl: 'subscriptions/views/subscriptions.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Subscriptions' | translate }}"
        }
    });

    $stateProvider.state('subscription', {
        abstract: true,
        url: '/subscriptions/:subscriptionId',
        permission: 'view_subscriptions',
        controller: 'SubscriptionDetailsController',
        templateUrl: 'subscriptions/details/views/subscription-details.html'
    })
    .state('subscription.info', {
        url: '',
        permission: 'view_subscriptions',
        templateUrl: 'subscriptions/details/views/subscription-info.html',
        ncyBreadcrumb: {
            label: "{{ subscription.name }}",
            parent: 'subscriptions'
        }
    })
    .state('subscription.products', {
        url: '/products',
        permission: 'view_subscriptions',
        controller: 'SubscriptionProductsController',
        templateUrl: 'subscriptions/details/views/subscription-products.html',
        ncyBreadcrumb: {
            label: "{{ 'Product Content' | translate }}",
            parent: 'subscription.info'
        }
    })
    .state('subscription.activation-keys', {
        url: '/activation-keys',
        permission: 'view_subscriptions',
        controller: 'SubscriptionActivationKeysController',
        templateUrl: 'subscriptions/details/views/subscription-activation-keys.html',
        ncyBreadcrumb: {
            label: "{{ 'Activation Keys' | translate }}",
            parent: 'subscription.info'
        }
    })
    .state('subscription.content-hosts', {
        url: '/content-hosts',
        permission: 'view_subscriptions',
        controller: 'SubscriptionContentHostsController',
        templateUrl: 'subscriptions/details/views/subscription-content-hosts.html',
        ncyBreadcrumb: {
            label: "{{ 'Content Hosts' | translate }}",
            parent: 'subscription.info'
        }
    });

    $stateProvider.state('subscriptions-manifest', {
        abstract: true,
        url: '/subscriptions/manifest',
        permission: 'import_manifest',
        controller: 'ManifestController',
        templateUrl: 'subscriptions/manifest/views/manifest.html'
    })
    .state('subscriptions-manifest.details', {
        url: '/details',
        permission: 'import_manifest',
        controller: 'ManifestDetailsController',
        templateUrl: 'subscriptions/manifest/views/manifest-details.html',
        ncyBreadcrumb: {
            label: "{{ 'Manifest Details' | translate }}",
            parent: 'subscriptions'
        }
    })
    .state('subscriptions-manifest.import', {
        url: '/import',
        permission: 'import_manifest',
        controller: 'ManifestImportController',
        templateUrl: 'subscriptions/manifest/views/manifest-import.html',
        ncyBreadcrumb: {
            label: "{{ 'Import Manifest' | translate }}",
            parent: 'subscriptions'
        }
    })
    .state('subscriptions-manifest.history', {
        url: '/history',
        permission: 'import_manifest',
        controller: 'ManifestHistoryController',
        templateUrl: 'subscriptions/manifest/views/manifest-import-history.html',
        ncyBreadcrumb: {
            label: "{{ 'Manifest History' | translate }}",
            parent: 'subscriptions'
        }
    });
}]);
