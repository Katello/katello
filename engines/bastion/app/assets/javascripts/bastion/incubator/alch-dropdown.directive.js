/**
 * @ngdoc directive
 * @name alchemy.directive:alchDropdown
 * @restrict EA
 *
 * @description
 *   Provides a "dropdown" menu.
 */
angular.module('alchemy').directive('alchDropdown', function () {
    return {
        restrict: 'EA',
        replace: true,
        scope: {
            'dropdown' : '=alchDropdown'
        },
        templateUrl: 'incubator/views/alch-dropdown.html',

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
