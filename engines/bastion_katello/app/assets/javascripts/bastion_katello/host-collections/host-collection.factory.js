/**
 * @ngdoc factory
 * @name  Bastion.host-collections.factory:HostCollection
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for host collections.
 */
angular.module('Bastion.host-collections').factory('HostCollection',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/host_collections/:id/:action', {id: '@id'}, {
            get: {method: 'GET', params: {fields: 'full'}},
            update: {method: 'PUT'},
            copy: {method: 'POST', params: {action: 'copy'}},
            removeHosts: {method: 'PUT', params: {action: 'remove_hosts'}},
            addHosts: {method: 'PUT', params: {action: 'add_hosts'}},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);
