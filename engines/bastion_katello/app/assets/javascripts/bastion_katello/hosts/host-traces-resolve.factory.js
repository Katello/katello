/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostTracesResolve
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for resolving traces on a set of systems.
 */
angular.module('Bastion.hosts').factory('HostTracesResolve',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/traces/:action', {}, {
            resolve: {method: 'PUT', isArray: true, params: {action: 'resolve'}}
        });

    }]
);
