/**
 * @ngdoc service
 * @name  Bastion.subscriptions.factory:Subscription
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for a subscription or list of subscriptions
 */
angular.module('Bastion.subscriptions').factory('Subscription', ['BastionResource', 'CurrentOrganization',

    function (BastionResource, CurrentOrganization) {
        return BastionResource('katello/api/v2/organizations/:org/subscriptions/:id/:action',
            {org: CurrentOrganization, id: '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                deleteManifest: {
                    method: 'POST',
                    url: 'katello/api/v2/organizations/:org/subscriptions/delete_manifest',
                    params: {'org': CurrentOrganization}
                },

                refreshManifest: {
                    method: 'PUT',
                    url: 'katello/api/v2/organizations/:org/subscriptions/refresh_manifest',
                    params: {'org': CurrentOrganization}
                },

                manifestHistory: {
                    method: 'GET',
                    url: 'katello/api/v2/organizations/:org/subscriptions/:action',
                    params: {action: 'manifest_history'},
                    isArray: true
                }
            });
    }]
);
