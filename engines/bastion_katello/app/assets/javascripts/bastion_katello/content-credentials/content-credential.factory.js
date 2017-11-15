/**
 * @ngdoc service
 * @name  Katello.content-credentials.factory:ContentCredential
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Content Credentials.
 */
angular.module('Bastion.content-credentials').factory('ContentCredential',
    ['BastionResource', 'CurrentOrganization',
    function (BastionResource, CurrentOrganization) {

        return BastionResource('katello/api/v2/content_credentials/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}},
                update: {method: 'PUT'},
                products: {method: 'GET', transformResponse:
                    function (data) {
                        var contentCredential = angular.fromJson(data);
                        var allProducts = {};
                        allProducts.length = 0;
                        allProducts.products = {};

                        function collectProducts(allP, thisP, usedAs) {
                            var key;
                            for (key in thisP) {
                                if (thisP.hasOwnProperty(key)) {
                                    thisP[key]["used_as"] = usedAs;
                                    allP.products[allP.length] = thisP[key];
                                    allP.length++;
                                }
                            }
                        }

                        collectProducts(allProducts, contentCredential.products, "GPG Key");
                        collectProducts(allProducts, contentCredential.ssl_ca_products, "SSL CA Cert");
                        collectProducts(allProducts, contentCredential.ssl_client_products, "SSL Client Cert");
                        collectProducts(allProducts, contentCredential.ssl_key_products, "SSL Client Key");

                        return {
                            total: allProducts.length,
                            subtotal: allProducts.length,
                            results: allProducts.products
                        };
                    }
                },
                repositories: {method: 'GET', transformResponse:
                    function (data) {
                        var contentCredential = angular.fromJson(data);
                        return {
                            total: contentCredential.repositories.length,
                            subtotal: contentCredential.repositories.length,
                            results: contentCredential.repositories
                        };
                    }
                }
            }
        );

    }]
);
