/**
 * Copyright 2013-2014 Red Hat, Inc.

 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc factory
 * @name  Bastion.activation-keys.factory:ActivationKey
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for activation keys.
 */
angular.module('Bastion.activation-keys').factory('ActivationKey',
    ['BastionResource', function (BastionResource) {
        return BastionResource('/katello/api/v2/activation_keys/:id/:action/:action2', {id: '@id'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            update: {method: 'PUT'},
            copy: {method: 'POST', params: {action: 'copy'}},
            releaseVersions: {method: 'GET', params: {action: 'releases'}},
            subscriptions: {method: 'GET', params: {action: 'subscriptions'}},
            products: {method: 'GET', params: {action: 'products'}},
            contentHosts: {method: 'GET', params: {action: 'systems'}},
            availableSubscriptions: {method: 'GET', params: {action: 'subscriptions', action2: 'available'}},
            removeSubscriptions: {method: 'PUT', isArray: false, params: {action: 'remove_subscriptions'}},
            addSubscriptions: {method: 'PUT', isArray: false, params: {action: 'add_subscriptions'}},
            hostCollections: {method: 'GET', params: {action: 'host_collections'}},
            availableHostCollections: {method: 'GET', params: {action: 'host_collections', action2: 'available'}},
            removeHostCollections: {method: 'PUT', isArray: false, params: {action: 'host_collections'}},
            addHostCollections: {method: 'POST', isArray: false, params: {action: 'host_collections'}},
            contentOverride: {method: 'PUT', isArray: false, params: {action: 'content_override'}}
        });
    }]
);
