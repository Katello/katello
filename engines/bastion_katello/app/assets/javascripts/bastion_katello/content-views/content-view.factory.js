/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentView
 *
 * @requires BastionResource
 * @requires translate
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with environments.
 */
angular.module('Bastion.content-views').factory('ContentView',
    ['BastionResource', 'translate', 'CurrentOrganization',
    function (BastionResource, translate, CurrentOrganization) {

        return BastionResource('katello/api/v2/content_views/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                copy: {method: 'POST', params: {action: 'copy'}},
                update: {method: 'PUT'},
                publish: {method: 'POST', params: {action: 'publish'}},
                removeAssociations: {method: 'PUT', params: {action: 'remove'}},
                versions: {method: 'GET', isArray: false, params: {action: 'content_view_versions'}},
                conflictingVersions: {method: 'GET', isArray: true, params: {action: 'content_view_versions'},
                    transformResponse: function (data) {
                        var response = angular.fromJson(data);
                        return _.reject(response.results, function (version) {
                            return version.environments.length === 0;
                        });
                    }
                },
                contentViewComponents: {method: 'GET', transformResponse: function (data) {
                    var contentView = angular.fromJson(data);
                    return {results: contentView.content_view_components};
                }},
                availablePuppetModules: {method: 'GET', params: {action: 'available_puppet_modules'},
                    transformResponse: function (data) {
                        return angular.fromJson(data);
                    }
                },
                availablePuppetModuleNames: {method: 'GET', params: {action: 'available_puppet_module_names'}},
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }]
);
