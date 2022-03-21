/**
 * @ngdoc service
 * @name  Bastion.repository.service:mirroringPolicy
 *
 * @requires translate
 *
 * @description
 *   Provides a mirroringPolicy for repositories
 */
angular.module('Bastion.repositories').service('MirroringPolicy',
    ['translate', function (translate) {

        this.defaultMirroringPolicy = 'mirror_content_only';

        this.mirroringPolicies = function(repoType) {
            var policies = {
                'additive': translate('Additive'),
                'mirror_content_only': translate('Content Only')
            };
            if (repoType === 'yum') {
                policies['mirror_complete'] = translate('Complete Mirroring');
            }
            return policies;
        };

        this.mirroringPolicyName = function (policy, repoType) {
            return this.mirroringPolicies(repoType)[policy];
        };
    }]
);
