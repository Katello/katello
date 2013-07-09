/**
 * @ngdoc directive
 * @name alchemy.directive:alchContainerScroll
 * @restrict A
 *
 * @requires $window
 *
 * @description
 *   The container scroll directive should be applied to a wrapping div around an element that
 *   you wish to have scrolling capabilities that is outside the standard browser flow.
 *
 * @example
 *   <pre>
       <div alch-container-scroll></div>
     </pre>
 */
angular.module('alchemy').directive('alchContainerScroll', ['$window', function ($window) {
    return {
        restrict: 'A',
        replace: true,
        transclude: true,
        template: '<div class="container-scroll-wrapper" ng-transclude></div>',

        link: function (scope, element, attrs) {

            angular.element($window).bind('resize', function() {
                var windowElement = angular.element($window),
                    windowWidth = windowElement.width(),
                    windowHeight = windowElement.height(),
                    offset = element.offset().top;

                if (attrs.controlWidth) {
                    element.find(attrs.controlWidth).width(windowWidth);
                }
                element.height(windowHeight - offset);

            }).trigger('resize');
        }
    };
}]);
