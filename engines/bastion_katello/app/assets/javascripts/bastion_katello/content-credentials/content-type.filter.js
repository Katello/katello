/**
 * @ngdoc object
 * @name Bastion.content-credentials.filter:contentTypeFilter
 *
 * @requires translate
 *
 * @description
 *   Provides filter functionality to replace cert with Certificates and gpg_key with GPG Key
 */

angular.module('Bastion.content-credentials').filter('contentTypeFilter',
    ['$filter', 'translate',
    function ($filter, translate) {
        return function (contentType) {
            var filtered = translate("Unsupported Type!");

            if (contentType === "cert") {
                filtered = translate("Certificate");
            } else if (contentType === "gpg_key") {
                filtered = translate("GPG Key");
            }
            return filtered;
        };
    }]
);
