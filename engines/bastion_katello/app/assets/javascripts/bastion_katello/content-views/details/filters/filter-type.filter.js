/**
 * @ngdoc filter
 * @name  Bastion.content-views.filter:FilterType
 *
 * @requires FilterHelper
 *
 * @description
 *   A filter to turn a filter type into an eaiser to read string.
 *
 * @example
 *   {{ filter.type | filterType }} will produce the string "Include" if true and "Exclude" if false;
 */
angular.module('Bastion.content-views').filter('filterType',
    ['FilterHelper', function (FilterHelper) {

        return function (type) {
            return FilterHelper.type(type);
        };

    }]
);
