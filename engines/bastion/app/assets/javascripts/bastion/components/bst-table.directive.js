/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstTable
 * @restrict A
 *
 * @requires $window
 *
 * @description
 *
 * @example
 */
angular.module('Bastion.components')
    .directive('bstTable', function () {
        return {
            restrict: 'A',
            replace: true,
            scope: {
                'table': '=bstTable',
                'rowSelect': '@',
                'rowChoice': '@'
            },
            controller: 'BstTableController',
            link: function (scope, element) {
                function checkForResults(rows) {
                    var table = scope.table,
                        tableElement = element.find('table'),
                        tableBody = tableElement.find('tbody'),
                        existingTr, numberOfColumns, messageTd, message;

                    tableBody.find('#noRowsTr').remove();

                    if (rows.length === 0 && !table.working) {
                        existingTr = tableBody.find('#noRowsTr');
                        numberOfColumns = tableElement.find('th').length;

                        if (table.searchTerm || table.searchCompleted) {
                            message = element.find("#noSearchResultsMessage").html();
                        } else {
                            message = element.find("#noRowsMessage").html();
                        }

                        messageTd = $('<td>').attr('colspan', numberOfColumns);
                        messageTd.html(message);

                        if (existingTr.length > 0) {
                            existingTr.html(messageTd);
                        } else {
                            tableBody.append($('<tr id="noRowsTr">'));
                            tableBody.find('tr').html(messageTd);
                        }

                    }
                }

                // Check for results and handle no rows message
                scope.$watch('table.rows', checkForResults);
            }
        };
    })
    .controller('BstTableController', ['$scope', function ($scope) {
        var rows = $scope.rows = [],
            headers = $scope.headers = [],
            self = this;

        this.selection = {allSelected: false, selectAllDisabled: false};

        if (!$scope.table.numSelected) {
            $scope.table.numSelected = 0;
        }

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
    .directive('bstTableHead', [function () {
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
            require: '^bstTable',
            restrict: 'A',
            scope: true,
            controller: 'BstTableHeadController',
            compile: function (tElement, tAttrs) {
                if (angular.isDefined(tAttrs.rowSelect)) {
                    tElement.prepend(rowSelectTemplate());
                } else if (angular.isDefined(tAttrs.rowChoice)) {
                    tElement.prepend(rowChoiceTemplate());
                }

                return function (scope, element, attrs, bstTableController) {
                    if (angular.isDefined(tAttrs.rowSelect) && angular.isDefined(scope.table)) {
                        scope.table.rowSelect = true;
                    } else if (angular.isDefined(tAttrs.rowChoice)) {
                        scope.table.rowChoice = true;
                    }

                    bstTableController.addHeader(scope.header);

                    scope.selection = bstTableController.selection;

                    scope.allSelected = function () {
                        bstTableController.selectAll(scope.selection.allSelected);
                    };
                };
            }
        };
    }])
    .controller('BstTableHeadController', ['$scope', function ($scope) {
        $scope.header = {
            columns: []
        };

        this.addColumn = function (column) {
            $scope.header.columns.push(column);
        };
    }])
    .directive('bstTableColumn', ['$compile', function ($compile) {
        var sortIconTemplate = '<th ng-click="table.sortBy(column)">' +
                                  '<i class="sort-icon" ng-show="table.resource.sort.by == column.id" ng-class="{\'fa fa-sort-down\': column.sortOrder == \'DESC\', \'fa fa-sort-up\': column.sortOrder == \'ASC\'}"></i>' +
                               '</th>';
        return {
            require: '^bstTableHead',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function ($scope) {
                $scope.column = { show: true };
            }],
            compile: function (tElement, tAttributes) {
                var newElement;

                if (tAttributes.hasOwnProperty("sortable")) {
                    newElement = angular.element(sortIconTemplate);
                    newElement.find('.sort-icon').before(tElement.html());
                    newElement.addClass('sortable');
                    newElement.addClass(tElement.attr('class'));
                    tElement.replaceWith(newElement);
                }
                return function (scope, element, attributes, bstTableHeadController) {
                    if (attributes.hasOwnProperty("sortable")) {
                        $compile(element)(scope);
                    }
                    scope.column.id = attributes.bstTableColumn;
                    bstTableHeadController.addColumn(scope.column);

                    scope.$watch('column.show', function (show) {
                        var display = show ? '' : 'none';
                        element.css('display', display);
                    });
                };
            }
        };
    }])
    .directive('bstTableRow', ['$parse', function ($parse) {
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
            return '<i class="fa fa-chevron-right selected-icon" ' +
                   'ng-show="' + activeTest + ' "></i>';
        };

        return {
            require: '^bstTable',
            restrict: 'A',
            scope: true,
            controller: 'BstTableRowController',
            compile: function (tElement, tAttrs) {

                if (angular.isDefined(tAttrs.activeRow)) {
                    tElement.find('td:first-child').append(activeRowTemplate(tAttrs.activeRow));
                }

                if (angular.isDefined(tAttrs.rowSelect)) {
                    tElement.prepend(rowSelectTemplate(tAttrs.rowSelect));
                }

                if (angular.isDefined(tAttrs.rowChoice)) {
                    tElement.prepend(rowChoiceTemplate(tAttrs.rowChoice));
                }

                if (angular.isDefined(tAttrs.activeRow)) {
                    tElement.find('td').attr('ng-class', '{ "active-row": ' + tAttrs.activeRow + ' }');
                }

                return function (scope, element, attrs, bstTableController) {
                    bstTableController.addRow(scope.row);

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
                        bstTableController.itemSelected(row);
                    };

                    scope.itemChosen = function (row) {
                        element.parent().find('.selected-row').removeClass('selected-row');
                        element.addClass('selected-row');
                        bstTableController.itemChosen(row);
                    };
                };
            }
        };
    }])
    .controller('BstTableRowController', ['$scope', function ($scope) {
        $scope.row = {
            cells: []
        };

        this.addCell = function (cell) {
            $scope.row.cells.push(cell);
        };
    }])
    .directive('bstTableCell', [function () {
        return {
            require: '^bstTableRow',
            restrict: 'A',
            scope: true,
            controller: ['$scope', function ($scope) {
                $scope.cell = { show: true };
            }],
            link: function (scope, element, attrs, bstTableRowController) {
                bstTableRowController.addCell(scope.cell);

                scope.$watch('cell.show', function (show) {
                    var display = show ? '' : 'none';
                    element.css('display', display);
                });
            }
        };
    }]);
