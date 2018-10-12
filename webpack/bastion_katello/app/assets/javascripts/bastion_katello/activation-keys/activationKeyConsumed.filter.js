/**
 * @ngdoc filter
 * @name  Bastion.activation-keys.filter:activationKeyConsumedFilter
 */
angular.module('Bastion.activation-keys').filter('activationKeyConsumedFilter',
    ['$filter', 'translate',
    function ($filter, translate) {
        return function (activationKey) {
            var quantity = $filter('unlimitedFilter')(activationKey['max_hosts'], activationKey['unlimited_hosts']);
            return translate('%(consumed)s out of %(quantity)s')
                .replace('%(consumed)s', activationKey['usage_count'])
                .replace('%(quantity)s', quantity);
        };
    }]
);
