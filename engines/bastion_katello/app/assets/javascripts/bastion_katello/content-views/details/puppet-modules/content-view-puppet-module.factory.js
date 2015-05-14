/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentViewPuppetModule
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with content view puppet modules.
 */
angular.module('Bastion.content-views').factory('ContentViewPuppetModule',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('/katello/api/v2/content_views/:contentViewId/content_view_puppet_modules/:id/:action',
            {id: '@id', contentViewId: '@contentViewId', 'organization_id': CurrentOrganization},
            {
                update: {method: 'PUT'}
            }
        );
    }]
);
