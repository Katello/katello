/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc filter
 * @name Bastion.utils.filter:as
 *
 * @requires $parse
 *
 * @description
 *   Adds variable to scope with the value passed in. This allows adding to the
 *   scope a variable that contains the result of multiple applied filters.
 *
 * @example
 *   <ul>
       <li ng-repeat="item in items | filter:customFilter | as:filteredItems"></li>
     </ul>
 */
angular.module('Bastion.utils').filter('as', ['$parse', function ($parse) {
    return function (value, path) {
        return $parse(path).assign(this, value);
    };
}]);
