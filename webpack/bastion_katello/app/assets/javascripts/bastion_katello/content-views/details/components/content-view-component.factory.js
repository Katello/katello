/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentViewComponent
 *
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a BastionResource for interacting with content view components.
 */
angular.module('Bastion.content-views').factory('ContentViewComponent',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/content_views/:compositeContentViewId/content_view_components/:id/:action',
            {id: '@id', compositeContentViewId: '@compositeContentViewId', 'organization_id': CurrentOrganization},
            {
                update: {method: 'PUT'},
                removeComponents: {
                    method: 'PUT',
                    isArray: false,
                    url: 'katello/api/v2/content_views/:compositeContentViewId/content_view_components/remove'
                },
                addComponents: {
                    method: 'PUT',
                    isArray: false,
                    url: 'katello/api/v2/content_views/:compositeContentViewId/content_view_components/add'
                }
            }
        );
    }]
);
