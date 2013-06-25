/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableScroll
 * @restrict A
 *
 * @requires $window
 *
 * @description
 *   The table scroll directive should be applied to a wrapping div around a table and
 *   turns that table into one that allows the body of the table to scroll.
 *
 * @example
 *   <pre>
       <div alch-table-scroll></div>
     </pre>
 */
angular.module('alchemy').directive('alchTableScroll', ['$window', function ($window) {
    return {
        restrict: 'A',
        replace: true,
        transclude: true,
        template: '<div class="table-scroll-wrapper" ng-transclude></div>',

        link: function (scope, element) {

            angular.element($window).bind('resize', function() {
                var windowElement = angular.element($window),
                    windowWidth = windowElement.width(),
                    windowHeight = windowElement.height(),
                    offset = element.offset().top;

                element.find('table').width(windowWidth);
                element.height(windowHeight - offset);

            }).trigger('resize');
        }
    };
}]);
