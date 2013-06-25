/**
 * @ngdoc directive
 * @name Bastion.components.directive:nutupaneTable
 * @restrict A
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('nutupaneTable', [function() {
    return {
        restrict: 'A',

        compile: function(tElement) {
            var originalTable = tElement.find('table'),
                clonedTable = originalTable.clone();

            clonedTable.find('tbody').remove();
            originalTable.find('thead').css('display', 'none');

            tElement.prepend(clonedTable);
        }
    };
}]);
