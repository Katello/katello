/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstAlert
 *
 * @requires $animate
 * @requires $timeout
 *
 * @description
 *   Simple directive for encapsulating an alert display.
 *
 * @example
 *   <pre>
 *     <div bst-alert="success"></div>
 *   </pre>
 */
angular.module('Bastion.components').directive('bstAlert', ['$animate', '$timeout', function ($animate, $timeout) {
    var SUCCESS_FADEOUT = 3000;

    return {
        templateUrl: 'components/views/bst-alert.html',
        transclude: true,
        scope: {
            type: '@bstAlert',
            close: '&'
        },
        link: function (scope, element, attrs) {
            var fadeOutAnimation;

            scope.fadePrevented = true;
            scope.closeable = 'close' in attrs;

            scope.startFade = function () {
                $timeout(function () {
                    if (!scope.fadePrevented) {
                        fadeOutAnimation = $animate.leave(element.find('.alert'));
                        fadeOutAnimation.then(function () {
                            scope.close();
                        });
                    }
                }, SUCCESS_FADEOUT);
            };

            scope.cancelFade = function () {
                scope.fadePrevented = true;
                if (fadeOutAnimation) {
                    $animate.cancel(fadeOutAnimation);
                }
            };

            // Automatically fade out success alerts
            if (scope.type === 'success') {
                scope.fadePrevented = false;
                scope.startFade();
            }
        }
    };
}]);
