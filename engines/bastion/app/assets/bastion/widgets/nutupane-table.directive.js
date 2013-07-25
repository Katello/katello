/**
 * @ngdoc directive
 * @name Bastion.components.directive:nutupaneTable
 * @restrict A
 *
 * @require $compile
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('nutupaneTable', ['$compile', function($compile) {
    return {
        restrict: 'A',

        link:  function (scope, element) {
            scope.$on("$stateChangeStart", function() {
                element.find('.cloned-nutupane-table').remove();
            });

            scope.$on("$stateChangeSuccess", function() {
                var originalTable = element.find('table'),
                    clonedTable = originalTable.clone();

                clonedTable.removeAttr("nutupane-table");
                clonedTable.addClass("cloned-nutupane-table");
                clonedTable.find('tbody').remove();
                originalTable.find('thead').css('display', 'none');

                element.prepend(clonedTable);
                $compile(element.find('.cloned-nutupane-table'))(scope);

                // Need to remove duplicate row-select created by second $compile
                var rowSelect = element.find(".row-select")[0];
                if (rowSelect) {
                    angular.element(rowSelect).remove();
                }
            });
        }
    };
}]);
