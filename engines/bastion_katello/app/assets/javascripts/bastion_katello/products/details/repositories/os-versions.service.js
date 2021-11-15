
/**
 * @ngdoc service
 * @name  Bastion.products.details.repositories.service:OSVersions
 *
 * @description
 *   Helper functions for repo osVersions.
 */

angular
    .module('Bastion.repositories')
    .service('OSVersions', function () {

        this.getOSVersionsOptions = function () {
            return [
                { name: 'No restriction', id: '' },
                { name: 'Red Hat Enterprise Linux 9 ', id: 'rhel-9' },
                { name: 'Red Hat Enterprise Linux 8 ', id: 'rhel-8' },
                { name: 'Red Hat Enterprise Linux 7 ', id: 'rhel-7' },
                { name: 'Red Hat Enterprise Linux 6 ', id: 'rhel-6' }
            ];
        };

        // return an array of OS versions
        this.osVersionsParam = function (osVersion) {
            var param = osVersion;
            if (osVersion && osVersion.hasOwnProperty('id')) {
                param = osVersion.id;
            }
            // exclude null, undefined, and ''
            return [param].filter(function (el) {
                return el && el !== '';
            });
        };

        // return the OS versions as comma-separated string
        this.formatOSVersions = function (osVersionList) {
            var individualVersions, versionStr;
            individualVersions = this.osVersionsParam(osVersionList);
            if (individualVersions) {
                versionStr = individualVersions.join(",");
            }
            return versionStr;
        };

    }
    );
