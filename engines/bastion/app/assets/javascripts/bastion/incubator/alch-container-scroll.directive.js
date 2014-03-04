/**
 * @ngdoc directive
 * @name alchemy.directive:alchContainerScroll
 * @restrict A
 *
 * @requires $window
 * @requires $timeout
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
angular.module('alchemy').directive('alchContainerScroll', ['$window', '$timeout', function ($window, $timeout) {
    return {
        restrict: 'A',

        compile: function (tElement, attrs) {
            tElement.addClass("container-scroll-wrapper");
            return function (scope, element) {
                var windowElement = angular.element($window);
                var addScroll = function () {
                    var windowWidth = windowElement.width(),
                        windowHeight = windowElement.height(),
                        offset = element.offset().top;

                    if (attrs.controlWidth) {
                        element.find(attrs.controlWidth).width(windowWidth);
                    }
                    element.outerHeight(windowHeight - offset);
                    element.height(windowHeight - offset);
                };
                windowElement.bind('resize', addScroll);
                $timeout(function () {
                    windowElement.trigger('resize');
                }, 0);
            };
        }
    };
}]);
