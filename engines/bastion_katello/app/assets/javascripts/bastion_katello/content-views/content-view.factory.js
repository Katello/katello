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

        return BastionResource('/katello/api/v2/content_views/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                copy: {method: 'POST', params: {action: 'copy'}},
                update: {method: 'PUT'},
                publish: {method: 'POST', params: {action: 'publish'}},
                removeAssociations: {method: 'PUT', params: {action: 'remove'}},
                versions: {method: 'GET', isArray: false, params: {action: 'content_view_versions'}},
                components: {method: 'GET', transformResponse: function (data) {
                    var contentView = angular.fromJson(data);
                    return {results: contentView.components};
                }},
                availablePuppetModules: {method: 'GET', params: {action: 'available_puppet_modules'},
                    transformResponse: function (data) {
                        var response = angular.fromJson(data);

                        angular.forEach(_.groupBy(response.results, 'author'), function (puppetModules) {
                            var latest = angular.copy(puppetModules[0]);
                            latest.version = translate('Use Latest (currently %s)').replace('%s', latest.version);
                            latest.useLatest = true;
                            response.results.push(latest);
                        });

                        return response;
                    }
                },
                availablePuppetModuleNames: {method: 'GET', params: {action: 'available_puppet_module_names'}},
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }]
);
