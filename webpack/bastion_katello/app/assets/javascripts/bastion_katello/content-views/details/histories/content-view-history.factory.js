/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentViewHistory
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with content view histories.
 */
angular.module('Bastion.content-views').factory('ContentViewHistory',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/content_views/:contentViewId/history/:action',
            {id: '@id', contentViewId: '@contentViewId', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {action: 'auto_complete_search'}}
            }
        );
    }]
);
