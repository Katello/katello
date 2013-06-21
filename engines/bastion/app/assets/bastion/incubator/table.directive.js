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
angular.module('alchemy').directive('alchTable', [function () {
    return {
        restrict: 'A',
        replace: true,
        scope: {
            'table' : '=alchTable',
            'rowSelect' : '@'
        },

        controller: ['$scope', '$element', function($scope, $element){
            var rows = this.rows = [],
                headers = this.headers = [];

            this.addRow = function(row) {
                rows.push(row);
            };

            this.addHeader = function(columns) {
                headers.push(columns);
            };

            this.itemSelected = function(row) {
                $scope.table.numSelected += row.selected ? 1 : -1;
                $scope.table.allSelected = false;
            };

            this.selectAll = $scope.table.selectAll = function(selected) {
                var table = $scope.table;

                table.allSelected = selected;

                $scope.table.numSelected = table.allSelected ? rows.length : 0;

                angular.forEach(rows, function(row) {
                    row.selected = table.allSelected;
                });
                angular.forEach(headers, function(columns) {
                    columns.selected = table.allSelected;
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

            $scope.table.moreResults = function(){
                var more = $scope.table.total > $scope.table.offset;

                more = more && $scope.table.allSelected;
                return more;
            };

            this.hasRowSelect = function() {
                return $scope.rowSelect;
            };

            $scope.table.reduceColumns = function(index) {
                angular.forEach(rows, function(row) {
                    angular.forEach(row.cells, function(cell, cellIndex) {
                        if (cellIndex !== index) {
                            cell.show = false;
                        }
                    });
                });

                angular.forEach(headers, function(header) {
                    angular.forEach(header, function(column, columnIndex) {
                        if (columnIndex !== index) {
                            column.show = false;
                        }
                    });
                });

                angular.element($element.find('table')[0]).addClass('table-reduced');
                angular.element($element.find('table')[1]).addClass('table-full');
                $element.find('[alch-table-scroll]').addClass('table-reduced');
            };

            $scope.table.showColumns = function() {
                angular.forEach(rows, function(row) {
                    angular.forEach(row.cells, function(cell) {
                        cell.show = true;
                    });
                });
                angular.forEach(headers, function(header) {
                    angular.forEach(header, function(column) {
                        column.show = true;
                    });
                });

                angular.element($element.find('table')[0]).removeClass('table-reduced');
                angular.element($element.find('table')[1]).removeClass('table-full');
                $element.find('[alch-table-scroll]').removeClass('table-reduced');
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
angular.module('alchemy').directive('alchTableHead', [function() {
    var rowSelectTemplate = '<th class="row-select">' +
                              '<input type="checkbox"' +
                                      'name="{{ row.id }}"' +
                                      'value="{{ row.id }}"' +
                                      'ng-model="row.selected"' +
                                      'ng-change="itemSelected(row)">' +
                            '</th>';
    return {
        require: '^alchTable',
        restrict: 'A',
        scope: true,

        compile: function(tElement, tAttrs) {
            if (tAttrs.rowSelect !== undefined) {
                tElement.prepend(rowSelectTemplate);
            }

            return function (scope, element, attrs, alchTableController) {
                alchTableController.addHeader(scope.row.columns);

                scope.itemSelected = function(row) {
                    alchTableController.selectAll(row.selected);
                };
            };
        },

        controller: ['$scope', function($scope) {
            $scope.row = {
                columns: []
            };

            this.addColumn = function(column) {
                $scope.row.columns.push(column);
            };
        }]
    };
}]);

/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableCell
 * @restrict A
 *
 * @description
 *
 * @example
 */
angular.module('alchemy').directive('alchTableColumn', [function() {
    return {
        require: '^alchTableHead',
        restrict: 'A',
        scope: true,

        link: function(scope, element, attrs, alchTableHeadController) {
            alchTableHeadController.addColumn(scope.column);

            scope.$watch('column.show', function(show) {
                if (show) {
                    element.removeClass('hidden');
                } else {
                    element.addClass('hidden');
                }
            });
        },

        controller: ['$scope', function($scope) {
            $scope.column = { show: true };
        }]
    };
}]);

/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableRow
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
angular.module('alchemy').directive('alchTableRow', ['$parse', function($parse) {
    var rowSelectTemplate = '<td class="row-select">' +
                              '<input type="checkbox"' +
                                      'name="{{ row.id }}"' +
                                      'value="{{ row.id }}"' +
                                      'ng-model="row.selected"' +
                                      'ng-change="itemSelected(row)">' +
                            '</td>';
    return {
        require: '^alchTable',
        restrict: 'A',
        scope: true,

        compile: function(tElement, tAttrs) {

            if (tAttrs.rowSelect !== undefined) {
                tElement.prepend(rowSelectTemplate);
            }

            return function(scope, element, attrs, alchTableController) {
                alchTableController.addRow(scope.row);

                if (attrs.rowSelect !== undefined) {
                    scope.$watch('row.selected', function(selected) {
                        if (selected) {
                            element.addClass('active-row');
                        } else {
                            element.removeClass('active-row');
                        }
                    });
                }

                scope.itemSelected = function(row) {
                    alchTableController.itemSelected(row);
                };
            };
        },

        controller: ['$scope', '$element', '$attrs', function($scope, $element, $attrs) {
            $scope.row = {
                model: $parse($attrs.alchTableRow)($scope),
                cells: []
            };

            this.addCell = function(cell) {
                $scope.row.cells.push(cell);
            };
        }]
    };
}]);

/**
 * @ngdoc directive
 * @name alchemy.directive:alchTableCell
 * @restrict A
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
angular.module('alchemy').directive('alchTableCell', [function() {
    return {
        require: '^alchTableRow',
        restrict: 'A',
        scope: true,

        link: function(scope, element, attrs, alchTableRowController) {
            alchTableRowController.addCell(scope.cell);

            scope.$watch('cell.show', function(show) {
                if (show) {
                    element.removeClass('hidden');
                } else {
                    element.addClass('hidden');
                }
            });
        },

        controller: ['$scope', function($scope) {
            $scope.cell = { show: true };
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
            var table = tElement.find('table').clone();

            angular.element(table).find('tbody').remove();

            table.find('thead').removeClass('hidden');
            tElement.prepend(table);
        }
    };
}]);
