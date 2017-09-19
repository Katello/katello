/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:ContentHost
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more content hosts.
 */
angular.module('Bastion.hosts').factory('HostSubscription',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/subscriptions/:action/', {id: '@id'}, {
            events: {method: 'GET', params: {action: 'events'}},
            autoAttach: {method: 'PUT', params: {action: 'auto_attach'}},
            removeSubscriptions: {method: 'put', isArray: false, params: {action: 'remove_subscriptions'}},
            addSubscriptions: {method: 'put', isArray: false, params: {action: 'add_subscriptions'}},
            repositorySets: {method: 'get', isArray: false, params: {action: 'product_content'}},
            contentOverride: {method: 'put', isArray: false, params: {action: 'content_override'}},
            releaseVersions: {method: 'get', isArray: false, params: {action: 'available_release_versions'}}
        });

    }]
);
