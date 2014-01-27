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
 * @name  alchemy.filter:capitalize
 *
 * @description
 *   A filter to capitalize the initial letter of a string.
 *
 * @example
 *   {{ 'blah' | capitalize }} will produce the string "Blah".
 */
angular.module('alchemy.format').filter('capitalize', function () {
    return function (input) {
        var capitalized = input;
        if (angular.isString(input)) {
            capitalized = input.substring(0, 1).toUpperCase() + input.substring(1);
        }
        return capitalized;
    };
});
