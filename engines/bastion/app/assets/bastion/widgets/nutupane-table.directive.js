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

        link: function(scope, element) {
            var originalTable, clonedTable, clonedThs;

            scope.$on("$stateChangeSuccess", function(event, newState, newParams, oldState) {
                // Only clone the table if the collapsed value changed or it's the first time.
                if (newState.collapsed !== oldState.collapsed || !oldState.name) {
                    element.find('.cloned-nutupane-table').remove();

                    originalTable = element.find('table');
                    clonedTable = originalTable.clone();

                    clonedTable.removeAttr("nutupane-table");
                    clonedTable.addClass("cloned-nutupane-table");
                    clonedTable.find('tbody').remove();

                    originalTable.find('thead').hide();

                    element.prepend(clonedTable);
                    $compile(element.find('.cloned-nutupane-table'))(scope);

                    // Need to remove duplicate row-select created by second $compile
                    var rowSelect = element.find(".row-select")[0];
                    if (rowSelect) {
                        angular.element(rowSelect).remove();
                    }

                    // Compile each cloned th individually with original th scope
                    // so sort will work.
                    clonedThs = element.find('.cloned-nutupane-table th');
                    angular.forEach(originalTable.find('th'), function(th, index) {
                        $compile(clonedThs[index])(angular.element(th).scope());
                    });
                } else {
                    element.find("table:not(.cloned-nutupane-table)").find('thead').hide();
                }
            });
        }
    };
}]);
