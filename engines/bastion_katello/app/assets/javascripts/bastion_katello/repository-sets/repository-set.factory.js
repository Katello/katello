/**
 * @ngdoc factory
 * @name  Bastion.host-collections.factory:RepositorySet
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for host collections.
 */
angular.module('Bastion.repository-sets').factory('RepositorySet',
    ['BastionResource', function (BastionResource) {
        return BastionResource('katello/api/v2/repository_sets/:id/:action', {id: '@id'}, {
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });
    }]
);
