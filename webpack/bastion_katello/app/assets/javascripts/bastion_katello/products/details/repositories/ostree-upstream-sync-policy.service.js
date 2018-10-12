/**
 * @ngdoc service
 * @name  Bastion.repository.service:ostreeUpstreamSyncPolicy
 *
 * @requires translate
 *
 * @description
 *   Provides a ostree upstream syncPolicies for repositories
 */
angular.module('Bastion.repositories').service('OstreeUpstreamSyncPolicy',
    ['translate', function (translate) {

        this.syncPolicies = {
            'latest': translate('Latest Only'),
            'all': translate('All History'),
            'custom': translate('Custom Depth')
        };

        this.syncPolicyName = function (policy, depth) {
            if (policy === "custom") {
                return translate('Custom Depth (Currently %s)').replace('%s', depth.toString());
            }
            return this.syncPolicies[policy];
        };
    }]
);
