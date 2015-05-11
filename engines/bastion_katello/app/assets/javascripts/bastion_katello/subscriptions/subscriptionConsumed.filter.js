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
    ['$filter', 'translate',
    function ($filter, translate) {
        return function (subscription) {
            var quantity = $filter('unlimitedFilter')(subscription.quantity);
            return translate('%(consumed)s out of %(quantity)s')
                .replace('%(consumed)s', subscription.consumed)
                .replace('%(quantity)s', quantity);
        };
    }]
);
