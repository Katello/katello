/**
 * @ngdoc service
 * @name  Bastion.content-views.service:FilterHelper
 *
 * @requires translate
 *
 * @description
 *   Provides helper methods for common Filter operations.
 */
angular.module('Bastion.content-views').service('FilterHelper',
    ['translate', function (translate) {

        this.contentTypes = {
            'rpm': translate('RPM'),
            'erratum': translate('Errata'),
            'package_group': translate('Package Groups'),
            'docker': translate('Container Image Tags'),
            'modulemd': translate('Module Streams')
        };

        this.contentType = function (type) {
            return this.contentTypes[type];
        };

        this.type = function (type) {
            return type ? translate('Include') : translate('Exclude');
        };

    }]
);
