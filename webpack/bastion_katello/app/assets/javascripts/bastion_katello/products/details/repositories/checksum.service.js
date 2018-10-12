/**
 * @ngdoc service
 * @name  Bastion.repository.service:checksum
 *
 * @requires translate
 *
 * @description
 *   Provides a checksum for repositories
 */
angular.module('Bastion.repositories').service('Checksum',
    ['translate', function (translate) {

        this.checksums = [{name: translate('Default'), id: null}, {id: 'sha256', name: 'sha256'}, {id: 'sha1', name: 'sha1'}];

        this.checksumType = function (checksum) {
            if (checksum === null) {
                checksum = translate('Default');
            }
            return checksum;
        };
    }]
);
