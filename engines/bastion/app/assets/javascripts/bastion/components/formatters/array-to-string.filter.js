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
        if (!toFormat) toFormat = [];
        separator = separator || ', ';
        if (typeof toFormat === 'string') toFormat = toFormat.split(separator);
        return toFormat.join(separator);
    };
}]);
