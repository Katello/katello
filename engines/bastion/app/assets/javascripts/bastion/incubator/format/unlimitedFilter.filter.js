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
 * @name  alchemy.filter:unlimitedFilter
 *
 * @description
 *   Used to format a display value as either a number or the translate text "Unlimited"
 *   based on a secondary boolean value.
 *
 * @example
 *  {{ hostCollection.max_content_hosts | unlimitedFilter:hostCollection.unlimited_content_hosts }}
 */
angular.module('alchemy.format').filter('unlimitedFilter', ['translate', function (translate) {
    return function (displayValue, unlimited) {
        if (unlimited || displayValue === -1) {
            displayValue = translate("Unlimited");
        } else if (displayValue) {
            displayValue = displayValue.toString();
        }
    
        return displayValue;
    };
}]);
