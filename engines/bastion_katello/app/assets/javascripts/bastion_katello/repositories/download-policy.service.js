/**
 * @ngdoc service
 * @name  Bastion.repository.service:downloadPolicy
 *
 * @requires translate
 *
 * @description
 *   Provides a downloadPolicy for repositories
 */
angular.module('Bastion.repositories').service('DownloadPolicy',
    ['translate', function (translate) {

        this.downloadPolicies = {
            'on_demand': translate('On Demand'),
            'background': translate('Background'),
            'immediate': translate('Immediate')
        };

        this.downloadPolicyName = function (policy) {
            return this.downloadPolicies[policy];
        };
    }]
);
