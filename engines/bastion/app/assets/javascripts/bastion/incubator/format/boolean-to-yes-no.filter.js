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
 * @name  alchemy.filter:booleanToYesNo
 *
 * @requires translate
 *
 * @description
 *   Provides a filter to convert a boolean to Yes/No
 */
angular.module('alchemy.format').filter('booleanToYesNo', ['translate', function (translate) {
    return function (boolValue, yesValue, noValue) {
        yesValue = yesValue || translate("Yes");
        noValue = noValue || translate("No");

        if (boolValue !== '' && boolValue !== null && boolValue !== undefined) {
            return (boolValue === true) ? yesValue : noValue;
        } else {
            return "";
        }
    };
}]);
