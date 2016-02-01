/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:Host
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more hosts.
 */
angular.module('Bastion.hosts').factory('Host',
    ['BastionResource', function (BastionResource) {
        return BastionResource('/api/v2/hosts/:id/:action', {id: '@id'}, {
            updateHostCollections: {method: 'PUT', params: {action: 'host_collections'}}
        });
    }]
);
