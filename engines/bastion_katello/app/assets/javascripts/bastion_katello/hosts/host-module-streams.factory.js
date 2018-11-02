/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:HostModuleStream
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the packages of a single content host
 */
angular.module('Bastion.hosts').factory('HostModuleStream',
    ['BastionResource', function (BastionResource) {

        return BastionResource('api/v2/hosts/:id/module_streams/:action', {id: '@id'}, {
            autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}}
        });

    }]
);
