/**
 * @ngdoc filter
 * @name  Bastion.components.formatters.filter:unlimitedFilter
 *
 * @description
 *   Used to format a display value as either a number or the translate text "Unlimited"
 *   based on a secondary boolean value.
 *
 * @example
 *  {{ hostCollection.max_content_hosts | unlimitedFilter:hostCollection.unlimited_content_hosts }}
 */
angular.module('Bastion.components.formatters').filter('unlimitedFilter', ['translate', function (translate) {
    return function (displayValue, unlimited) {
        if (unlimited || displayValue === -1) {
            displayValue = translate("Unlimited");
        } else if (displayValue) {
            displayValue = displayValue.toString();
        }

        return displayValue;
    };
}]);
