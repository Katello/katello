/**
 * @ngdoc filter
 * @name  Bastion.components.formatters.filter:arrayToString
 *
 * @description
 *
 *
 * @example
 *
 */
angular.module('Bastion.components.formatters').filter('arrayToString', [function () {
    return function (toFormat, separator) {
        separator = separator || ', ';
        return toFormat.join(separator);
    };
}]);
