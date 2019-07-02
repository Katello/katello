/**
 * @ngdoc service
* @name  Bastion.repository.service:httpProxyPolicy
*
* @requires translate
* @requires globalContentProxy
*
* @description
*   Provides HTTP Proxy policy and name display
*/
angular.module('Bastion.repositories').service('HttpProxyPolicy',
    ['translate', 'globalContentProxy', function (translate, globalContentProxy) {

        this.globalContentProxyName = "";

        if (globalContentProxy) {
            this.globalContentProxyName = translate("Global Default") + " (" + globalContentProxy + ")";
        } else {
            this.globalContentProxyName = translate("Global Default (None)");
        }

        this.policies = [ {name: this.globalContentProxyName, label: 'global_default_http_proxy'},
                            {name: translate("No HTTP Proxy"), label: 'none'},
                            {name: translate("Use specific HTTP Proxy"), label: 'use_selected_http_proxy'}];

        this.displayHttpProxyPolicyName = function (policy) {
            var policies = {
              'global_default_http_proxy': this.globalContentProxyName,
              'none': translate("No HTTP Proxy"),
              'use_selected_http_proxy': translate("Use specific HTTP Proxy")
            };
            return policies[policy];
        };

        this.displayHttpProxyName = function (proxies, proxyId) {
            var findProxy = function(proxy) {
                return proxy.id === this.id;
            };

            var foundProxy = proxies.find(findProxy, { id: proxyId });

            if (proxies.length === 0) {
                return translate("No HTTP Proxies found");
            }

            if (foundProxy) {
                return foundProxy.name;
            }

            return "";
        };
    }]
);
