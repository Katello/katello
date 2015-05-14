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

        return BastionResource('/katello/api/v2/packages/:id',
            {'id': '@id'},
            {
                autocomplete: {
                    method: 'GET',
                    url: '/katello/packages/auto_complete',
                    transformResponse: function (data) {
                        data = angular.fromJson(data);
                        return {results: data};
                    }
                }
            });

    }]
);
