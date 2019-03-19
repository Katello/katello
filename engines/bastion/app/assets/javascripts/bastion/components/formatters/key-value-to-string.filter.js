/**
 * @ngdoc filter
 * @name  Bastion.components.formatters.filter:keyValueToString
 *
 * @description
 *
 *
 * @example
 *
 */
angular.module('Bastion.components.formatters').filter('keyValueToString', [function () {
    return function (toFormat, options) {
        var keyName, valueName, separator;
        options = options || {};
        keyName = options.keyName || 'keyname';
        valueName = options.valueName || 'value';
        separator = options.separator || ': ';

        if (!(toFormat instanceof Array)) {
            toFormat = [toFormat];
        }

        return _.map(toFormat, function (entry) {
            return [entry[keyName], entry[valueName]].join(separator);
        }).join(', ');
    };
}]);
