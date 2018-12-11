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
        var repoTypeMap = {
            "gpg_key_repos": "GPG Key",
            "ssl_ca_root_repos": "SSL CA Cert",
            "ssl_client_root_repos": "SSL Client Cert",
            "ssl_key_root_repos": "SSL Client Key"
        };

        var productTypeMap = {
            "gpg_key_products": "GPG Key",
            "ssl_ca_products": "SSL CA Cert",
            "ssl_client_products": "SSL Client Cert",
            "ssl_key_products": "SSL Client Key"
        };

        function appendData(allData, fullCredential, usedAs) {
            angular.forEach(fullCredential, function(data) {
                data.usedAs = usedAs;
                allData.push(data);
            });
        }

        function parseContentCredentialData(data, typeMap) {
            var contentCredential = angular.fromJson(data);
            var allData = [];
            _.forOwn(contentCredential, function(value, key) {
                if (typeMap.hasOwnProperty(key)) {
                    appendData(allData, value, typeMap[key]);
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
                        var allProducts = parseContentCredentialData(data, productTypeMap);
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
                        var allRepos = parseContentCredentialData(data, repoTypeMap);
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
