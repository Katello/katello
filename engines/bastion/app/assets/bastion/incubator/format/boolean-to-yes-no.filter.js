/**
 Copyright 2013 Red Hat, Inc.

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
 * @requires gettext
 *
 * @description
 *   Provides a filter to convert a boolean to Yes/No
 */
angular.module('alchemy.format').filter('booleanToYesNo', ['gettext', function (gettext) {
    return function (boolValue, yesValue, noValue) {
        yesValue = yesValue || gettext("Yes");
        noValue = noValue || gettext("No");

        if (boolValue !== undefined && boolValue !== null) {
            return (boolValue === true) ? yesValue : noValue;
        } else {
            return "";
        }
    };
}]);
