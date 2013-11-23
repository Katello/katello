/**
 * @ngdoc directive
 * @name alchemy.directive:alchFlyout
 * @restrict EA
 *
 * @description
 *   Provides a "flyout" sub-menu for menu items with one or more
 *   child menu items.
 */
angular.module('alchemy').directive('alchFlyout', function() {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'flyout' : '=alchFlyout'
        },
        templateUrl: '../incubator/views/alch-flyout.html'
    };
});
