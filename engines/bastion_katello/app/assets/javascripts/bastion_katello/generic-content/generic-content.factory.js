/**
 * @ngdoc service
 * @name  Bastion.generic-content.factory:GenericContent
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for GenericContent
 */
angular.module('Bastion.generic-content').factory('GenericContent',
    ['BastionResource', function (BastionResource) {

        return BastionResource('katello/api/v2/:content_type_name/:id/',
            {'content_type_name': '@content_type_name', 'sort_by': 'name', 'sort_order': 'DESC'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }]
);
