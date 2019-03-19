/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstFlyout
 * @restrict EA
 *
 * @description
 *   Provides a "flyout" sub-menu for menu items with one or more
 *   child menu items.
 */
angular.module('Bastion.components').directive('bstFlyout', function () {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'flyout': '=bstFlyout'
        },
        templateUrl: 'components/views/bst-flyout.html'
    };
});
