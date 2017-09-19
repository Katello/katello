/**
 * @ngdoc service
 * @name  Bastion.repositories.factory:Repository
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for product or list of repositories.
 */
angular.module('Bastion.repositories').factory('Repository',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/repositories/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                update: { method: 'PUT' },
                sync: { method: 'POST', params: { action: 'sync' } },
                removePackages: { method: 'PUT', params: { action: 'remove_packages'}},
                removeContent: { method: 'PUT', params: { action: 'remove_content'}},
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                repositoryTypes: {method: 'GET', isArray: true, params: {id: 'repository_types'}},
                republish: {method: 'PUT', params: { action: 'republish' }}
            }
        );

    }]
);

/**
 * @ngdoc service
 * @name  Bastion.repositories.factory:RepositoryBulkAction
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for bulk actions on repositories.
 */
angular.module('Bastion.repositories').factory('RepositoryBulkAction',
    ['BastionResource', 'CurrentOrganization', function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/repositories/bulk/:action',
            {'organization_id': CurrentOrganization},
            {
                removeRepositories: {method: 'PUT', params: {action: 'destroy'}},
                syncRepositories: {method: 'POST', params: {action: 'sync'}}
            }
        );

    }]
);
