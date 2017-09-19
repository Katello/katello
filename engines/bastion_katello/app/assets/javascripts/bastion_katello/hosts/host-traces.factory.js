/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostTraces
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the packages of a single content host
 */
angular.module('Bastion.hosts').factory('HostTraces',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/traces/:action', {id: '@id'}, {
            get: {method: 'GET', isArray: false}
        });

    }]
);
