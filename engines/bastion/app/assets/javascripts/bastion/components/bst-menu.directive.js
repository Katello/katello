/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstMenu
 * @restrict EA
 * @requires $window
 *
 * @description
 *   Provides a menu.
 */
angular.module('Bastion.components').directive('bstMenu', ['$window', function ($window) {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'menu': '=bstMenu',
            'compact': '@'
        },
        templateUrl: 'components/views/bst-menu.html',
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

            if (angular.isDefined(attrs.compact)) {
                elementOriginalOffset = angular.element(element).offset().top;

                angular.element($window).bind('scroll', function () {
                    var windowScrollTop = angular.element($window).scrollTop();

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
