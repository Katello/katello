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
 * @name  Bastion.subscriptions.filter:subscriptionConsumedFilter
 *
 * @description
 *
 *
 * @example
 *
 */
angular.module('Bastion.subscriptions').filter('subscriptionConsumedFilter',
    ['$filter', 'gettext',
    function ($filter, gettext) {
        return function (subscription) {
            var quantity = $filter('unlimitedFilter')(subscription.quantity);
            return gettext('%(consumed)s out of %(quantity)s')
                .replace('%(consumed)s', subscription.consumed)
                .replace('%(quantity)s', quantity);
        };
    }]
);
