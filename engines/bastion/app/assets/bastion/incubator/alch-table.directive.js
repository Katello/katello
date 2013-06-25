/**
 * @ngdoc directive
 * @name alchemy.directive:alchTable
 * @restrict A
 *
 * @description
 *
 * @example
 */
angular.module('alchemy')
    .directive('alchTable', [function () {
        return {
            restrict: 'A',
            replace: true,
            scope: {
                'table' : '=alchTable',
                'rowSelect' : '@'
            },
            controller: 'AlchTableController'
        };
    }])
    .controller('AlchTableController', ['$scope', '$element', function($scope, $element) {
        var rows = $scope.rows = [],
            headers = $scope.headers = [];

        $scope.table.numSelected = 0;
        $scope.table.allSelected = false;

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

        $scope.table.reduceColumns = function(index) {
            angular.forEach(rows, function(row) {
                angular.forEach(row.cells, function(cell, cellIndex) {
                    if (index !== cellIndex) {
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

            $scope.shrinkTable(true);
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

            $scope.shrinkTable(false);
        };

        $scope.shrinkTable = function(shrink) {
            if (shrink) {
                angular.element($element.find('table')[0]).addClass('table-reduced');
                angular.element($element.find('table')[1]).addClass('table-full');
                $element.find('[alch-table-scroll]').addClass('table-reduced');
            } else {
                angular.element($element.find('table')[0]).removeClass('table-reduced');
                angular.element($element.find('table')[1]).removeClass('table-full');
                $element.find('[alch-table-scroll]').removeClass('table-reduced');
            }
        };
    }])
    .directive('alchTableHead', [function() {
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
            controller: 'AlchTableHeadController',
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
            }
        };
    }])
    .controller('AlchTableHeadController', ['$scope', function($scope) {
        $scope.row = {
            columns: []
        };

        this.addColumn = function(column) {
            $scope.row.columns.push(column);
        };
    }])
    .directive('alchTableColumn', [function() {
        return {
            require: '^alchTableHead',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function($scope) {
                $scope.column = { show: true };
            }],
            link: function(scope, element, attrs, alchTableHeadController) {
                alchTableHeadController.addColumn(scope.column);

                scope.$watch('column.show', function(show) {
                    var display = show ? '' : 'none';
                    element.css('display', display);
                });
            }
        };
    }])
    .directive('alchTableRow', [function() {
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
            controller: 'AlchTableRowController',
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

                        scope.itemSelected = function(row) {
                            alchTableController.itemSelected(row);
                        };
                    }
                };
            }
        };
    }])
    .controller('AlchTableRowController', ['$scope', function($scope) {
        $scope.row = {
            cells: []
        };

        this.addCell = function(cell) {
            $scope.row.cells.push(cell);
        };
    }])
    .directive('alchTableCell', [function() {
        return {
            require: '^alchTableRow',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function($scope) {
                $scope.cell = { show: true };
            }],
            link: function(scope, element, attrs, alchTableRowController) {
                alchTableRowController.addCell(scope.cell);

                scope.$watch('cell.show', function(show) {
                    var display = show ? '' : 'none';
                    element.css('display', display);
                });
            }
        };
    }]);
