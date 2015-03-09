/**
 Copyright 2013-2014 Red Hat, Inc.

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
 * @name  Bastion.subscriptions
 *
 * @description
 *   Module for subscriptions
 */
angular.module('Bastion.subscriptions', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.organizations',
    'Bastion.components',
    'Bastion.components.formatters'
]);

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
        abstract: true,
        controller: 'SubscriptionsController',
        templateUrl: 'subscriptions/views/subscriptions.html'
    });

    $stateProvider.state('subscriptions.index', {
        url: '/subscriptions',
        permission: 'view_subscriptions',
        views: {
            'table': {
                templateUrl: 'subscriptions/views/subscriptions-table-full.html'
            }
        }
    })

    .state('subscriptions.details', {
        abstract: true,
        url: '/subscriptions/:subscriptionId',
        permission: 'view_subscriptions',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'subscriptions/views/subscriptions-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SubscriptionDetailsController',
                templateUrl: 'subscriptions/details/views/subscription-details.html'
            }
        }
    })
    .state('subscriptions.details.info', {
        url: '/info',
        permission: 'view_subscriptions',
        collapsed: true,
        templateUrl: 'subscriptions/details/views/subscription-info.html'
    })
    .state('subscriptions.details.products', {
        url: '/products',
        permission: 'view_subscriptions',
        collapsed: true,
        controller: 'SubscriptionProductsController',
        templateUrl: 'subscriptions/details/views/subscription-products.html'
    })
    .state('subscriptions.details.associations-activation-keys', {
        url: '/associations/activation-keys',
        permission: 'view_subscriptions',
        collapsed: true,
        controller: 'SubscriptionAssociationsActivationKeysController',
        templateUrl: 'subscriptions/details/views/subscription-associations-activation-keys.html'
    })
    .state('subscriptions.details.associations-content-hosts', {
        url: '/associations/content-hosts',
        permission: 'view_subscriptions',
        collapsed: true,
        controller: 'SubscriptionAssociationsContentHostsController',
        templateUrl: 'subscriptions/details/views/subscription-associations-content-hosts.html'
    })

    // manifest states
    .state('subscriptions.manifest', {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'subscriptions/views/subscriptions-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ManifestController',
                templateUrl: 'subscriptions/manifest/views/manifest.html'
            }
        }
    })
    .state('subscriptions.manifest.import', {
        url: '/subscriptions/manifest/import',
        permission: 'import_manifest',
        collapsed: true,
        controller: 'ManifestImportController',
        templateUrl: 'subscriptions/manifest/views/manifest-import.html'
    })
    .state('subscriptions.manifest.details', {
        url: '/subscriptions/manifest/details',
        permission: 'import_manifest',
        collapsed: true,
        controller: 'ManifestDetailsController',
        templateUrl: 'subscriptions/manifest/views/manifest-details.html'
    })
    .state('subscriptions.manifest.history', {
        url: '/subscriptions/manifest/history',
        permission: 'import_manifest',
        collapsed: true,
        controller: 'ManifestHistoryController',
        templateUrl: 'subscriptions/manifest/views/manifest-import-history.html'
    });

}]);
