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
                'table': '=alchTable',
                'rowSelect': '@',
                'rowChoice': '@'
            },
            controller: 'AlchTableController'
        };
    }])
    .controller('AlchTableController', ['$scope', function ($scope) {
        var rows = $scope.rows = [],
            headers = $scope.headers = [],
            self = this;

        this.selection = {allSelected: false, selectAllDisabled: false};

        $scope.table.numSelected = 0;
        $scope.table.chosenRow = null;

        $scope.table.getSelected = function () {
            var selectedRows = [];
            angular.forEach($scope.table.rows, function (row, rowIndex) {
                if (row.selected === true) {
                    selectedRows.push($scope.table.rows[rowIndex]);
                }
            });
            return selectedRows;
        };

        $scope.table.selectAllDisabled = false;

        this.disableSelectAll = $scope.table.disableSelectAll = function () {
            self.selection.selectAllDisabled = true;
        };

        this.enableSelectAll = $scope.table.enableSelectAll = function () {
            self.selection.selectAllDisabled = false;
        };

        $scope.table.allSelected = function () {
            return self.selection.allSelected;
        };

        this.addRow = function (row) {
            rows.push(row);

            if (headers.length) {
                angular.forEach(headers[0].columns, function (column, columnIndex) {
                    if (row.cells[columnIndex]) {
                        row.cells[columnIndex].show = column.show;
                    }
                });
            }
        };

        this.addHeader = function (columns) {
            headers.push(columns);
        };

        this.itemSelected = function (row) {
            $scope.table.numSelected += row.selected ? 1 : -1;
            self.selection.allSelected = false;
        };

        this.itemChosen = function (row) {
            $scope.table.chosenRow = row;
        };

        this.selectAll = $scope.table.selectAll = function (selected) {
            var table = $scope.table,
                rowsSelected = 0;

            self.selection.allSelected = selected;
            angular.forEach(table.rows, function (row) {
                if (!row.unselectable) {
                    row.selected = self.selection.allSelected;
                    rowsSelected = rowsSelected + 1;
                }
            });
            $scope.table.numSelected = selected ? rowsSelected : 0;
        };

    }])
    .directive('alchTableHead', [function () {
        var rowSelectTemplate = function () {
            return '<th class="row-select">' +
                      '<input type="checkbox"' +
                              'ng-model="selection.allSelected"' +
                              'ng-disabled="selection.selectAllDisabled"' +
                              'ng-change="allSelected()">' +
                    '</th>';
        }, rowChoiceTemplate = function () {
            return '<th translate class="row-select"></th>';
        };

        return {
            require: '^alchTable',
            restrict: 'A',
            scope: true,
            controller: 'AlchTableHeadController',
            compile: function (tElement, tAttrs) {
                if (tAttrs.rowSelect !== undefined) {
                    tElement.prepend(rowSelectTemplate());
                } else if (tAttrs.rowChoice !== undefined) {
                    tElement.prepend(rowChoiceTemplate());
                }

                return function (scope, element, attrs, alchTableController) {
                    if (tAttrs.rowSelect !== undefined) {
                        scope.table.rowSelect = true;
                    } else  if (tAttrs.rowChoice !== undefined) {
                        scope.table.rowChoice = true;
                    }

                    alchTableController.addHeader(scope.header);

                    scope.selection = alchTableController.selection;

                    scope.allSelected = function () {
                        alchTableController.selectAll(scope.selection.allSelected);
                    };
                };
            }
        };
    }])
    .controller('AlchTableHeadController', ['$scope', function ($scope) {
        $scope.header = {
            columns: []
        };

        this.addColumn = function (column) {
            $scope.header.columns.push(column);
        };
    }])
    .directive('alchTableColumn', ['$compile', function ($compile) {
        var sortIconTemplate = '<th ng-click="table.sortBy(column)">' +
                                  '<i class="sort-icon" ng-show="table.resource.sort.by == column.id" ng-class="{\'icon-sort-down\': column.sortOrder == \'DESC\', \'icon-sort-up\': column.sortOrder == \'ASC\'}"></i>' +
                               '</th>';
        return {
            require: '^alchTableHead',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function ($scope) {
                $scope.column = { show: true };
            }],
            compile: function (element, attributes) {
                if (attributes.hasOwnProperty("sortable")) {
                    var newElement = angular.element(sortIconTemplate);
                    newElement.find('.sort-icon').before(element.html());
                    newElement.addClass('sortable');
                    newElement.addClass(element.attr('class'));
                    element.replaceWith(newElement);
                }
                return function (scope, element, attributes, alchTableHeadController) {
                    if (attributes.hasOwnProperty("sortable")) {
                        $compile(element)(scope);
                    }
                    scope.column.id = attributes["alchTableColumn"];
                    alchTableHeadController.addColumn(scope.column);

                    scope.$watch('column.show', function (show) {
                        var display = show ? '' : 'none';
                        element.css('display', display);
                    });
                };
            }
        };
    }])
    .directive('alchTableRow', ['$parse', function ($parse) {
        var rowSelectTemplate, rowChoiceTemplate, activeRowTemplate;

        rowSelectTemplate = function (model) {
            return '<td class="row-select">' +
                      '<input type="checkbox"' +
                              'ng-model="' + model + '.selected"' +
                              'ng-disabled="' + model + '.unselectable"' +
                              'ng-change="itemSelected(' + model + ')">' +
                   '</td>';
        };

        rowChoiceTemplate = function (model) {
            return '<td class="row-choice">' +
                      '<input type="radio"' +
                              'ng-model="table.chosenRow"' +
                              'ng-value="' + model + '"' +
                              'ng-click="itemChosen(' + model + ')">' +
                   '</td>';
        };

        activeRowTemplate = function (activeTest) {
            return '<i class="icon-chevron-right selected-icon" ' +
                   'ng-show="' + activeTest  + ' "></i>';
        };

        return {
            require: '^alchTable',
            restrict: 'A',
            scope: true,
            controller: 'AlchTableRowController',
            compile: function (tElement, tAttrs) {

                if (tAttrs.activeRow !== undefined) {
                    tElement.find('td:first-child').append(activeRowTemplate(tAttrs.activeRow));
                }

                if (tAttrs.rowSelect !== undefined) {
                    tElement.prepend(rowSelectTemplate(tAttrs.rowSelect));
                }

                if (tAttrs.rowChoice !== undefined) {
                    tElement.prepend(rowChoiceTemplate(tAttrs.rowChoice));
                }

                if (tAttrs.activeRow !== undefined) {
                    tElement.find('td').attr('ng-class', '{ "active-row": ' + tAttrs.activeRow + ' }');
                }

                return function (scope, element, attrs, alchTableController) {
                    alchTableController.addRow(scope.row);

                    if (attrs.rowSelect) {
                        scope.model = $parse(attrs.rowSelect)(scope);

                        if ($parse(attrs.rowSelectIf)(scope)) {
                            scope.model.unselectable = true;
                        }

                        scope.$watch('model.selected', function (selected) {
                            if (selected) {
                                element.addClass('selected-row');
                            } else {
                                element.removeClass('selected-row');
                            }
                        });
                    } else if (attrs.rowChoice) {
                        scope.model = $parse(attrs.rowChoice)(scope);
                    }

                    if (attrs.activeRow) {
                        scope.activeTest = $parse(attrs.activeRow)(scope);
                    }

                    scope.itemSelected = function (row) {
                        alchTableController.itemSelected(row);
                    };

                    scope.itemChosen = function (row) {
                        element.parent().find('.selected-row').removeClass('selected-row');
                        element.addClass('selected-row');
                        alchTableController.itemChosen(row);
                    };
                };
            }
        };
    }])
    .controller('AlchTableRowController', ['$scope', function ($scope) {
        $scope.row = {
            cells: []
        };

        this.addCell = function (cell) {
            $scope.row.cells.push(cell);
        };
    }])
    .directive('alchTableCell', [function () {
        return {
            require: '^alchTableRow',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function ($scope) {
                $scope.cell = { show: true };
            }],
            link: function (scope, element, attrs, alchTableRowController) {
                alchTableRowController.addCell(scope.cell);

                scope.$watch('cell.show', function (show) {
                    var display = show ? '' : 'none';
                    element.css('display', display);
                });
            }
        };
    }]);
