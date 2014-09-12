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
 * @name  Bastion.content-views.filter:FilterType
 *
 * @requires FilterHelper
 *
 * @description
 *   A filter to turn a filter type into an eaiser to read string.
 *
 * @example
 *   {{ filter.type | filterType }} will produce the string "Include" if true and "Exclude" if false;
 */
angular.module('Bastion.content-views').filter('filterType',
    ['FilterHelper', function (FilterHelper) {

        return function (type) {
            return FilterHelper.type(type);
        };

    }]
);
