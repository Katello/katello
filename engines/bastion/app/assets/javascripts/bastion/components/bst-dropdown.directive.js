/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstDropdown
 * @restrict EA
 *
 * @description
 *   Provides a "dropdown" menu.
 */
angular.module('Bastion.components').directive('bstDropdown', function () {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'dropdown': '=bstDropdown'
        },
        templateUrl: 'components/views/bst-dropdown.html',

        controller: ['$scope', function ($scope) {
            $scope.setHover = function (item, mousein) {
                item.active = mousein;
            };

            $scope.isRight = function (direction) {
                return direction === 'right';
            };
        }]
    };
});
