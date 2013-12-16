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
 * @name  Bastion.activation-keys
 *
 * @description
 *   Module for activation keys related functionality.
 */
angular.module('Bastion.activation-keys', [
    'ngResource',
    'ui.router',
    'Bastion.utils',
    'Bastion.widgets'
]);

angular.module('Bastion.activation-keys').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('activation-keys', {
        abstract: true,
        controller: 'ActivationKeysController',
        templateUrl: 'activation-keys/views/activation-keys.html'
    })
    .state('activation-keys.index', {
        url: '/activation-keys',
        views: {
            'table': {
                templateUrl: 'activation-keys/views/activation-keys-table-full.html'
            }
        }
    })
    .state('activation-keys.new', {
        url: '/activation-keys/new',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'activation-keys/views/activation-keys-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewActivationKeyController',
                templateUrl: 'activation-keys/new/views/activation-key-new.html'
            }
        }
    });

    $stateProvider.state("activation-keys.details", {
        abstract: true,
        url: '/activation-keys/:activationKeyId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'activation-keys/views/activation-keys-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ActivationKeyDetailsController',
                templateUrl: 'activation-keys/details/views/activation-key-details.html'
            }
        }
    })
    .state('activation-keys.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'ActivationKeyDetailsInfoController',
        templateUrl: 'activation-keys/details/views/activation-key-info.html'
    })
    .state('activation-keys.details.subscriptions', {
        abstract: true,
        collapsed: true,
        templateUrl: 'activation-keys/details/views/activation-key-subscriptions.html'
    })
    .state('activation-keys.details.subscriptions.list', {
        url: '/subscriptions',
        collapsed: true,
        controller: 'ActivationKeySubscriptionsController',
        templateUrl: 'activation-keys/details/views/activation-key-subscriptions-list.html'
    })
    .state('activation-keys.details.subscriptions.add', {
        url: '/add-subscriptions',
        collapsed: true,
        controller: 'ActivationKeyAddSubscriptionsController',
        templateUrl: 'activation-keys/details/views/activation-key-add-subscriptions.html'
    });



}]);
