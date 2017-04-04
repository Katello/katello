/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:OstreeUpstreamSyncPolicyFilter
 *
 * @requires translate
 * @requires OstreeUpstreamSyncPolicy
 *
 * @description
 *   Provides the Ostree Upstream Sync policy filter functionality for the repository details info page.
 */

angular.module('Bastion.components.formatters').filter('ostreeUpstreamSyncPolicyFilter', ['translate', 'OstreeUpstreamSyncPolicy', function (translate, OstreeUpstreamSyncPolicy) {
    return function (displayValue, repository) {
        var policy = repository["ostree_upstream_sync_policy"];
        if ( policy === "custom") {
            return OstreeUpstreamSyncPolicy.syncPolicyName(policy, repository["ostree_upstream_sync_depth"]);
        }
        return OstreeUpstreamSyncPolicy.syncPolicyName(policy);
    };
}]);

angular.module('Bastion.components.formatters').filter('upstreamPasswordFilter', [function () {
    return function (displayValue, repository) {
        if (repository["upstream_password_exists"]) {
            return "******";
        }
        return null;
    };
}]);
