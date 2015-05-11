/**
 * @ngdoc service
 * @name  Bastion.content-hosts.factory:ContentHostPackage
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the packages of a single content host
 */
angular.module('Bastion.content-hosts').factory('ContentHostPackage',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/systems/:id/packages/:action', {id: '@uuid'}, {
            get: {method: 'GET', isArray: false},
            remove: {method: 'PUT', params: {action: 'remove'}},
            install: {method: 'PUT', params: {action: 'install'}},
            update: {method: 'PUT', params: {action: 'upgrade'}},
            updateAll: {method: 'PUT', params: {action: 'upgrade_all'}}
        });

    }]
);
