/**
 * @ngdoc service
 * @name  Katello.content-credentials.factory:ContentCredential
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Content Credentials.
 */
angular.module("Bastion.content-credentials").factory("ContentCredential", [
    "BastionResource",
    "CurrentOrganization",
    function(BastionResource, CurrentOrganization) {
        function appendData(collection, fullData, usedAs) {
            angular.forEach(fullData, function(data) {
                data.usedAs = usedAs;
                collection.push(data);
            });
        }

        function sortContentCredentialData(data, cases) {
            var contentCredential = angular.fromJson(data);
            var allData = [];
            _.forOwn(contentCredential, function(value, key) {
                switch (key) {
                    case cases[0]:
                        appendData(allData, value, "GPG Key");
                        break;
                    case cases[1]:
                        appendData(allData, value, "SSL CA Cert");
                        break;
                    case cases[2]:
                        appendData(allData, value, "SSL Client Cert");
                        break;
                    case cases[3]:
                        appendData(allData, value, "SSL Client Key");
                        break;
                }
            });
            return allData;
        }

        return BastionResource(
            "katello/api/v2/content_credentials/:id/:action",
            { "id": "@id", "organization_id": CurrentOrganization },
            {
                autocomplete: {
                    method: "GET",
                    isArray: true,
                    params: { id: "auto_complete_search" }
                },
                update: { method: "PUT" },
                products: {
                    method: "GET",
                    transformResponse: function(data) {
                        var allProducts = sortContentCredentialData(data, [
                            "gpg_key_products",
                            "ssl_ca_products",
                            "ssl_client_products",
                            "ssl_key_products"
                        ]);
                        return {
                            total: allProducts.length,
                            subtotal: allProducts.length,
                            results: allProducts
                        };
                    }
                },
                repositories: {
                    method: "GET",
                    transformResponse: function(data) {
                        var allRepos = sortContentCredentialData(data, [
                            "gpg_key_repos",
                            "ssl_ca_root_repos",
                            "ssl_client_root_repos",
                            "ssl_key_root_repos"
                        ]);
                        return {
                            total: allRepos.length,
                            subtotal: allRepos.length,
                            results: allRepos
                        };
                    }
                }
            }
        );
    }
]);
