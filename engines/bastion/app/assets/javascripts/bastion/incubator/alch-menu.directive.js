/**
 * @ngdoc directive
 * @name alchemy.directive:alchMenu
 * @restrict EA
 * @requires $window
 *
 * @description
 *   Provides a menu.
 */
angular.module('alchemy').directive('alchMenu', ['$window', function ($window) {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'menu': '=alchMenu',
            'compact' : '@'
        },
        templateUrl: 'incubator/views/alch-menu.html',
        controller: ['$scope', function ($scope) {
            $scope.dropdown = {};

            $scope.handleHover = function (item, mousein) {
                if (item.type === 'dropdown' && mousein) {
                    item.active = true;
                    $scope.dropdown = item.items;
                    $scope.dropdown.show = true;
                    $scope.dropdown.direction = $scope.menu.location;
                } else {
                    $scope.dropdown.show = false;

                    if (item !== $scope.menu.activeItem) {
                        item.active = false;
                    }
                }
            };

        }],
        link: function (scope, element, attrs) {
            var elementOriginalOffset;

            if (attrs.compact !== undefined) {
                elementOriginalOffset = $(element).offset().top;

                angular.element($window).bind('scroll', function () {
                    var windowScrollTop = $($window).scrollTop();

                    if (windowScrollTop > elementOriginalOffset + 2) {
                        element.parent().addClass('compact');
                    } else if (windowScrollTop < elementOriginalOffset) {
                        element.parent().removeClass('compact');
                    }
                });
            }
        }
    };
}]);
