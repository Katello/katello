/**
 * @ngdoc service
 * @name  Bastion.environments.factory:Environment
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with environments.
 */
angular.module('Bastion.environments').factory('Environment',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/environments/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: {method: 'PUT'}
            }
        );

    }]
);
