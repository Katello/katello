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
*/

/**
 * @ngdoc service
 * @name  Bastion.subscriptions.service:SubscriptionsHelper
 *
 * @description
 *   Helper service that contains functionality common amongst subscriptions.
 */
angular.module('Bastion.subscriptions').service('SubscriptionsHelper',
    function () {

        this.groupByProductName = function (rows) {
            var grouped,
                offset,
                subscription;

            grouped = {};
            for (offset = 0; offset < rows.length; offset += 1) {
                subscription = rows[offset];
                if (grouped[subscription['product_name']] === undefined) {
                    grouped[subscription['product_name']] = [];
                }
                grouped[subscription['product_name']].push(subscription);
            }

            return grouped;
        };

        this.getSelectedSubscriptionAmounts = function (table) {
            var selected,
                amount;

            selected = [];
            angular.forEach(table.getSelected(), function (subscription) {
                if (subscription['multi_entitlement']) {
                    amount = subscription.amount;
                    if (!amount) {
                        amount = 0;
                    }
                } else {
                    amount = 1;
                }
                selected.push({"id": subscription.id, "quantity": amount});
            });
            return selected;
        };

        this.getSelectedSubscriptions = function (table) {
            var selected;

            selected = [];
            angular.forEach(table.getSelected(), function (subscription) {
                selected.push({"id": subscription.id});
            });
            return selected;
        };

    }
);
