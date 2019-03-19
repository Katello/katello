/**
 * @ngdoc filter
 * @name  Bastion.components.formatters.filter:booleanToYesNo
 *
 * @requires translate
 *
 * @description
 *   Provides a filter to convert a boolean to Yes/No
 */
angular.module('Bastion.components.formatters').filter('booleanToYesNo', ['translate', function (translate) {
    return function (boolValue, yesValue, noValue) {
        yesValue = yesValue || translate("Yes");
        noValue = noValue || translate("No");

        if (boolValue !== '' && boolValue !== null && angular.isDefined(boolValue)) {
            return (boolValue === true) ? yesValue : noValue;
        }

        return "";
    };
}]);
