/**
 * @ngdoc service
 * @name  Katello.http-proxies.factory:HttpProxy
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Http Proxies.
 */
angular.module("Bastion.http-proxies").factory("HttpProxy", [
    "BastionResource",
    "CurrentOrganization",


    function(BastionResource, CurrentOrganization) {
            return BastionResource(
                        "api/v2/http_proxies/:id/:action",
                        { "id": "@id", "organization_id": CurrentOrganization }
                    );
        }
]);
