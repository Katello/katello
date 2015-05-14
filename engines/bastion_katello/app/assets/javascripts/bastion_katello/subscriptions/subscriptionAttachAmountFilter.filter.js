/**
 * @ngdoc filter
 * @name  Bastion.subscriptions.filter:subscriptionAttachAmountFilter.filter.js
 *
 * @requires translate
 *
 */
angular.module('Bastion.subscriptions').filter('subscriptionAttachAmountFilter',
    ['translate',
    function (translate) {
        return function (subscription) {
            var amount = subscription.amount;
            return (!amount || amount < 1) ? translate("Automatic") : amount;
        };
    }]
);
