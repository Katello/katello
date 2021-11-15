angular.module('Bastion.components.formatters').filter('upstreamPasswordFilter', [function () {
    return function (displayValue, repository) {
        if (repository["upstream_auth_exists"]) {
            return '%(username) / ********'.replace('%(username)', repository["upstream_username"]);
        }
        return null;
    };
}]);

angular.module('Bastion.components.formatters').filter('ansibleAuthFilter', [function () {
    return function (displayValue, repository) {
        if (repository["ansible_collection_auth_url"] && repository["ansible_collection_auth_token"]) {
            return '%(auth_url) / ********'.replace('%(auth_url)', repository["ansible_collection_auth_url"]);
        }
        return null;
    };
}]);

angular.module('Bastion.components.formatters').filter('httpProxyDetailsFilter', ['HttpProxyPolicy', function (HttpProxyPolicy) {
    return function (displayValue, repository) {
        var message = '%(proxyPolicy)'.replace('%(proxyPolicy)', HttpProxyPolicy.displayHttpProxyPolicyName(repository["http_proxy_policy"]));

        if (repository["http_proxy_policy"] === 'use_selected_http_proxy' && repository["http_proxy"]) {
            message += " (" + repository["http_proxy"].name + ")";
        }

        return message;
    };
}]);

angular.module('Bastion.components.formatters').filter('yumIgnorableContentFilter', ['YumContentUnits', function (YumContentUnits) {
    return function (displayValue, repository) {
        var names;
        if (_.isEmpty(repository["ignorable_content"])) {
            return null;
        }

        names = _.map(repository["ignorable_content"], function (key) {
            return YumContentUnits.unitName(key);
        });

        return names.join(", ");
    };
}]);
