/**
 * @ngdoc service
 * @name  Bastion.organizations.factory:Organization
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for organization(s).
 */
angular.module('Bastion.organizations').factory('Organization',
    ['BastionResource', 'CurrentOrganization', function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/organizations/:id/:action',
            {id: '@id'},
            {
                update: { method: 'PUT' },
                releaseVersions: {method: 'GET', params: {action: 'releases'}},

                select: {
                    method: 'GET',
                    url: 'organizations/:label/select'
                },
                repoDiscover: { method: 'POST', params: {action: 'repo_discover'}},
                cancelRepoDiscover: {method: 'POST', params: {action: 'cancel_repo_discover'}},
                paths: {
                    method: 'GET',
                    url: 'katello/api/v2/organizations/:id/environments/paths',
                    isArray: true,
                    transformResponse: function (data) {
                        return angular.fromJson(data).results;
                    }
                },
                readableEnvironments: {
                    method: 'GET',
                    url: 'katello/api/v2/organizations/:id/environments/paths',
                    isArray: true,
                    transformResponse: function (data) {
                        // transform [{environments : [{id, name, permissions: {readable : true}}]}]
                        // to [[{id, name, select: true}]]
                        return _.map(angular.fromJson(data).results, function (path) {
                            return _.map(path.environments, function (env) {
                                env.select = env.permissions.readable;
                                return env;
                            });
                        });
                    }
                },
                redhatProvider: {
                    method: 'GET',
                    url: 'katello/api/v2/organizations/:organization_id/redhat_provider',
                    params: {'organization_id': CurrentOrganization}
                }
            }
        );

    }]
);
