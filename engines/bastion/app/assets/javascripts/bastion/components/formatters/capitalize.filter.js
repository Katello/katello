/**
 * @ngdoc filter
 * @name  Bastion.components.formatters.filter:capitalize
 *
 * @description
 *   A filter to capitalize the initial letter of a string.
 *
 * @example
 *   {{ 'blah' | capitalize }} will produce the string "Blah".
 */
angular.module('Bastion.components.formatters').filter('capitalize', function () {
    return function (input) {
        var capitalized = input;
        if (angular.isString(input)) {
            capitalized = input.substring(0, 1).toUpperCase() + input.substring(1);
        }
        return capitalized;
    };
});
