/**
 * @ngdoc directive
 * @name alchemy.directive:alchTable
 * @restrict A
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('alchTable', ['$window', '$location', function ($window, $location) {
    return {
        restrict: 'A',
        transclude: true,
        replace: true,
        scope: {
            'table' : '=alchTable',
            'rowSelect' : '@'
        },
        template: '<table ng-transclude></table>',

        link: function (scope, element) {
            // Load the next page of results if the
            scope.$watch('table.data.rows', function (newValue, oldValue) {
                if (scope.table.hasOwnProperty('nextPage')) {
                    // Only do this when directive first initializes
                    if ((newValue && !oldValue) || $location.search()) {
                        var space = $window.innerHeight - (element[0].offsetTop + element[0].offsetHeight);
                        if (space > 0) {
                            scope.table.nextPage();
                        }
                    }
                }
            });

        },

        controller: ['$scope', function($scope){
            $scope.table.selectAll = function(selected) {
                var table = $scope.table;

                table.allSelected = selected;

                $scope.table.numSelected = table.allSelected ? table.items.length : 0;

                angular.forEach($scope.table.items, function(item){
                    item.selected = table.allSelected;
                });
            };

            $scope.table.itemSelected = function(selected) {
                $scope.table.numSelected += selected ? 1 : -1;
                $scope.table.allSelected = false;
            };

            $scope.table.numSelected = 0;
            $scope.table.allSelected = false;
            $scope.table.scrollDistance = 0;

            $scope.showCell = function(cell){
                var toShow;

                angular.forEach($scope.table.data.columns, function(header){
                    if( header.id === cell.columnId ){
                        toShow = header.show;
                    }
                });

                return toShow;
            };

            $scope.table.getSelectedRows = function () {
                var selected = [];
                angular.forEach($scope.table.data.rows, function (row) {
                    if (row.selected) {
                        selected.push(row);
                    }
                });
                return selected;
            };

            $scope.table.moreResults = function(){
                var more = $scope.table.total > $scope.table.offset;

                more = more && $scope.table.allSelected;
                return more;
            };

            this.hasRowSelect = function() {
                return $scope.rowSelect;
            };
        }]
    };
}]);

/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableHead
 * @restrict AC
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('alchTableHead', [function () {
    return {
        restrict: 'A',
        require: '^alchTable',
        transclude: true,
        scope: {
            'table': '=alchTableHead',
        },
        templateUrl: 'component/templates/table-head.html',

        link: function(scope, element, attrs, alchTableController){
            scope.rowSelect = alchTableController.hasRowSelect();

            scope.selectAll = function(selected) {
                scope.table.selectAll(selected);
            };
        }
    };
}]);

/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableBody
 * @restrict AC
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('alchTableBody', [function () {
    return {
        restrict: 'A',
        transclude: 'element',
        require: '^alchTable',
        scope: {
            'items': '=items',
        },
        templateUrl: 'component/templates/table-body.html',

        link: function(scope, element, attrs, alchTableController){
            scope.rowSelect = alchTableController.hasRowSelect();

            scope.itemSelected = function(selected) {
                alchTableController.itemSelected(selected);
            };
        }
    };
}]);
