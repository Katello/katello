/**
 * @ngdoc service
 * @name  Bastion.repository.service:YumContentUnits
 *
 * @requires translate
 *
 * @description
 *   Provides content type units for yum
 */
angular.module('Bastion.repositories').service('YumContentUnits',
    ['translate', function (translate) {
        this.units = {
            'rpm': translate('RPM'),
            'drpm': translate('Delta RPM'),
            'srpm': translate('Source RPM'),
            'erratum': translate('Errata'),
            'distribution': translate('Distribution')
        };

        this.unitName = function (unit) {
            return this.units[unit];
        };
    }]
);
