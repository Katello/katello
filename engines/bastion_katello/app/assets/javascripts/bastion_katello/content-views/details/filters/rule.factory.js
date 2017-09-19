/**
 * @ngdoc service
 * @name  Bastion.content-views.filters.factory:Filter
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for interacting with content view filter rules.
 */
angular.module('Bastion.content-views').factory('Rule',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/content_view_filters/:filterId/rules/:ruleId',
            {ruleId: '@id', filterId: '@content_view_filter_id'},
            {
                update: {method: 'PUT'}
            }
        );

    }]
);
