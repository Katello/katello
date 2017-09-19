/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostPackage
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the packages of a single content host
 */
angular.module('Bastion.hosts').factory('HostPackage',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/packages/:action', {id: '@id'}, {
            get: {method: 'GET', isArray: false},
            remove: {method: 'PUT', params: {action: 'remove'}},
            install: {method: 'PUT', params: {action: 'install'}},
            update: {method: 'PUT', params: {action: 'upgrade'}},
            updateAll: {method: 'PUT', params: {action: 'upgrade_all'}},
            autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}},
            applicable: {method: 'GET', params: {action: 'applicable'}}
        });

    }]
);
