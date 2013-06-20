/**
 * @ngdoc directive
 * @name alchemy.directive:alchTable
 * @restrict A
 *
 * @requires $window
 * @requires $location
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
 * @name alchemy.directive:alchTableScroll
 * @restrict A
 *
 * @requires $window
 *
 * @description
 *   The table scroll directive should be applied to a wrapping div around a table and
 *   turns that table into one that allows the body of the table to scroll.
 *
 * @example
 *   <pre>
       <div alch-table-scroll></div>
     </pre>
 */
angular.module('alchemy').directive('alchTableScroll', ['$window', function ($window) {
    return {
        restrict: 'A',
        replace: true,
        transclude: true,
        template: '<div class="table-scroll-wrapper" ng-transclude></div>',

        link: function (scope, element) {

            angular.element($window).bind('resize', function() {
                var windowWidth = angular.element($window).width(),
                    windowHeight = angular.element($window).height(),
                    offset = element.offset().top;

                element.find('table').width(windowWidth);
                element.height(windowHeight - offset);

            }).trigger('resize');
        }
    };
}]);
