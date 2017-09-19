/**
 * @ngdoc service
 * @name  Bastion.providers.factory:Package
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for product or list of providers.
 */
angular.module('Bastion.packages').factory('Package',
    ['BastionResource', 'CurrentOrganization', function (BastionResource) {

        return BastionResource('katello/api/v2/packages/:id',
            {'id': '@id'},
            {
                'autocomplete': {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                'autocompleteName': {method: 'GET', isArray: false, params: {id: 'auto_complete_name'},
                    transformResponse: function (data) {
                        data = angular.fromJson(data);
                        return {results: data};
                    }
                },
                'autocompleteArch': {method: 'GET', isArray: false, params: {id: 'auto_complete_arch'},
                    transformResponse: function (data) {
                        data = angular.fromJson(data);
                        return {results: data};
                    }
                }
            });
    }]
);
