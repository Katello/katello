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

        this.checksums = [
            {name: translate('Default'), id: null},
            {id: 'sha256', name: 'sha256'},
            {id: 'sha384', name: 'sha384'},
            {id: 'sha512', name: 'sha512'}
        ];

        this.checksumType = function (checksum) {
            if (checksum === null) {
                checksum = translate('Default');
            }
            return checksum;
        };
    }]
);
