/**
 * @ngdoc filter
 * @name  Bastion.content-views.filter:FilterContentType
 *
 * @requires FilterHelper
 *
 * @description
 *   A filter to turn a filter type into an eaiser to read string.
 *
 * @example
 *   {{ 'rpm' | filterContentType }} will produce the string "Packages".
 */
angular.module('Bastion.content-views').filter('filterContentType',
    ['FilterHelper', function (FilterHelper) {

        return function (type) {
            return FilterHelper.contentType(type);
        };

    }]
);
