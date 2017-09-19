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

        return BastionResource('katello/api/v2/activation_keys/:id/:action/:action2', {id: '@id'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            update: {method: 'PUT'},
            copy: {method: 'POST', params: {action: 'copy'}},
            releaseVersions: {method: 'GET', params: {action: 'releases'}},
            subscriptions: {method: 'GET', params: {action: 'subscriptions'}},
            contentHosts: {method: 'GET', params: {action: 'systems'}},
            removeSubscriptions: {method: 'PUT', isArray: false, params: {action: 'remove_subscriptions'}},
            addSubscriptions: {method: 'PUT', isArray: false, params: {action: 'add_subscriptions'}},
            hostCollections: {method: 'GET', params: {action: 'host_collections'}},
            availableHostCollections: {method: 'GET', params: {action: 'host_collections', action2: 'available'}},
            removeHostCollections: {method: 'PUT', isArray: false, params: {action: 'host_collections'}},
            addHostCollections: {method: 'POST', isArray: false, params: {action: 'host_collections'}},
            contentOverride: {method: 'PUT', isArray: false, params: {action: 'content_override'}},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
            repositorySets: {method: 'GET', params: {action: 'product_content'}}
        });
    }]
);
