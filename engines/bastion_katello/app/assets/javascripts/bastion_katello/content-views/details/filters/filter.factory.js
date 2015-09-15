/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:Filter
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for interacting with content view filters.
 */
angular.module('Bastion.content-views').factory('Filter',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/content_view_filters/:filterId/:action',
            {filterId: '@id', 'content_view_id': '@content_view.id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {filterId: 'auto_complete_search'}},
                update: {method: 'PUT'},
                availableErrata: {
                    method: 'GET',
                    params: {action: 'errata', 'available_for': 'content_view_filter'}
                },
                errata: {
                    method: 'GET',
                    params: {action: 'errata'}
                },
                availablePackageGroups: {
                    method: 'GET',
                    params: {action: 'package_groups', 'available_for': 'content_view_filter'}
                },
                packageGroups: {
                    method: 'GET',
                    params: {action: 'package_groups'}
                }
            }
        );

    }]
);
