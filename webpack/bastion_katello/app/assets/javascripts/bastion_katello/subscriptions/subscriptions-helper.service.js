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
                if (angular.isUndefined(grouped[subscription.name])) {
                    grouped[subscription.name] = [];
                }
                grouped[subscription.name].push(subscription);
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

        this.getAmountSelectorValues = function (subscription) {
            var step, value, values;

            step = subscription['instance_multiplier'];
            if (!step || step < 1) {
                step = 1;
            }
            values = [];
            for (value = step; value < subscription.quantity && values.length < 5; value += step) {
                values.push(value);
            }
            values.push(subscription.quantity);
            return values;
        };

        this.getSelectedSubscriptions = function (table) {
            var selected;

            selected = [];
            angular.forEach(table.getSelected(), function (subscription) {
                selected.push({"id": subscription.id, "quantity": subscription.quantity_consumed});
            });
            return selected;
        };
    }
);
