/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentViewVersion
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with Content View Versions.
 */
angular.module('Bastion.content-views.versions').factory('ContentViewVersion',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/content_view_versions/:id/:action',
            {id: '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: {method: 'PUT'},
                incrementalUpdate: {method: 'POST', params: {action: 'incremental_update'}},
                promote: {method: 'POST', params: {action: 'promote'}},
                republishRepositories: {method: 'PUT', params: {action: 'republish_repositories'}}
            }
        );

    }]
);
