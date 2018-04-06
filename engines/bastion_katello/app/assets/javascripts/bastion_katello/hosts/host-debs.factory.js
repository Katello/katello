/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostDeb
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the deb packages of a single content host
 */
angular.module('Bastion.hosts').factory('HostDeb',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/debs/:action', {id: '@id'}, {
            get: {method: 'GET', isArray: false},
            autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}},
            applicable: {method: 'GET', params: {action: 'applicable'}}
        });

    }]
);
