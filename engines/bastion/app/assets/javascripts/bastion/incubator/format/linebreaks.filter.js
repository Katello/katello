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
 * @name  alchemy.filter:linebreaks
 *
 * @description
 *   Replace new lines with <br/> elements.
 *
 * @example
 *   {{ 'I have \n more than \n one line' | linebreaks }}
 *
 *   I have <br/>
 *   more than <br/>
 *   one line
 */
angular.module('alchemy.format').filter('linebreaks', [function () {
    return function (string) {
        var formatted = string;
        if (angular.isString(string)) {
            formatted = string.replace(/\n/g, '<br/>');
        }
        return formatted;
    };
}]);
