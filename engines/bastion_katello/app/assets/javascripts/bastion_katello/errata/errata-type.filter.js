/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc filter
 * @name  Bastion.errata.filter:errataType
 *
 * @requires translate
 *
 * @description
 *   A filter to turn an errata type into an easier to read, translated string.
 *
 * @example
 *   {{ 'bugfix' | errataType }} will produce the translated string "Bug Fix Advisory".
 */
angular.module('Bastion.errata').filter('errataType', ['translate', function (translate) {
    return function (type) {
        var errataType;

        switch (type) {
        case 'bugfix':
            errataType = translate('Bug Fix Advisory');
            break;
        case 'enhancement':
            errataType = translate('Product Enhancement Advisory');
            break;
        case 'security':
            errataType = translate('Security Advisory');
            break;
        default:
            errataType = type;
        }

        return errataType;
    };

}]);
