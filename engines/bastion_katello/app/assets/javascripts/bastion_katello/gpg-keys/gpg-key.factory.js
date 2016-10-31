/**
 * @ngdoc service
 * @name  Katello.gpg-keys.factory:GPGKey
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for GPG keys.
 */
angular.module('Bastion.gpg-keys').factory('GPGKey',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('/katello/api/v2/gpg_keys/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: {method: 'PUT'},
                products: {method: 'GET', transformResponse:
                    function (data) {
                        var gpgKey = angular.fromJson(data);
                        return {
                            total: gpgKey.products.length,
                            subtotal: gpgKey.products.length,
                            results: gpgKey.products
                        };
                    }
                },
                repositories: {method: 'GET', transformResponse:
                    function (data) {
                        var gpgKey = angular.fromJson(data);
                        return {
                            total: gpgKey.repositories.length,
                            subtotal: gpgKey.repositories.length,
                            results: gpgKey.repositories
                        };
                    }
                }
            }
        );

    }]
);
