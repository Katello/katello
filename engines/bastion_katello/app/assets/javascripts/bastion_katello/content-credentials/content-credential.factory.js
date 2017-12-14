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

                        collectProducts(allProducts, contentCredential.gpg_key_products, "GPG Key");
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
                        var allRepos = {};
                        allRepos.length = 0;
                        allRepos.repositories = {};

                        function collectRepos(allR, thisR, usedAs) {
                            var key;
                            for (key in thisR) {
                                if (thisR.hasOwnProperty(key)) {
                                    thisR[key]["used_as"] = usedAs;
                                    allR.repositories[allR.length] = thisR[key];
                                    allR.length++;
                                }
                            }
                        }

                        collectRepos(allRepos, contentCredential.gpg_key_repos, "GPG Key");
                        collectRepos(allRepos, contentCredential.ssl_ca_repos, "SSL CA Cert");
                        collectRepos(allRepos, contentCredential.ssl_client_repos, "SSL Client Cert");
                        collectRepos(allRepos, contentCredential.ssl_key_repos, "SSL Client Key");

                        return {
                            total: allRepos.length,
                            subtotal: allRepos.length,
                            results: allRepos.repositories
                        };
                    }
                }
            }
        );

    }]
);
