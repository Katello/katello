/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */


describe('Directive: alchTable', function() {
    var scope,
        compile,
        tableElement,
        chooseTableElement;

    beforeEach(module('alchemy'));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        scope.table = {};
        scope.table.rows = [{
            name: 'Spring Bock',
            style: 'ale'
        },{
            name: 'Pilsner',
            style: 'lager'
        },{
            name: 'Quadrupel',
            style: 'beer',
            unselectable: true
        }]
    });

    beforeEach(function() {
        tableElement = angular.element(
            '<div alch-table="table">' +
              '<table>' +
                '<thead class="hidden">' +
                  '<tr alch-table-head row-select>' +
                    '<th alch-table-column>{{ "Name" }}</th>' +
                  '</tr>' +
                '</thead>' +
                '<tbody>' +
                  '<tr alch-table-row ng-repeat="item in table.rows" row-select="item" active-row="true">' +
                    '<td alch-table-cell>{{ item.name }}</td>' +
                    '<td alch-table-cell>{{ item.style }}</td>' +
                 '</tr>' +
                '</tbody>' +
              '</table>' +
            '</div>');

        chooseTableElement = angular.element(
            '<div alch-table="table">' +
              '<table>' +
                '<thead class="hidden">' +
                  '<tr alch-table-head row-choice>' +
                    '<th alch-table-column>{{ "Name" }}</th>' +
                  '</tr>' +
                '</thead>' +
                '<tbody>' +
                  '<tr alch-table-row ng-repeat="item in table.rows" row-choice="item">' +
                    '<td alch-table-cell>{{ item.name }}</td>' +
                    '<td alch-table-cell>{{ item.style }}</td>' +
                  '</tr>' +
                '</tbody>' +
              '</table>' +
            '</div>');


        compile(tableElement)(scope);
        compile(chooseTableElement)(scope);
        scope.$digest();
    });

    describe('alchTable controller', function() {
        var element,
            tableController;

        beforeEach(inject(function($controller) {
            tableController = $controller('AlchTableController', {$scope: scope, $element: tableElement});
        }));

        it("should append a row", function() {
            var row1 = {}, row2 = {};

            expect(scope.rows).toEqual([]);

            tableController.addRow(row1);
            tableController.addRow(row2);

            expect(scope.rows).toEqual([row1, row2]);
        });

        it("should append a table head with columns", function() {
            var col1 = {}, col2 = {},
                tableHead = { columns: [col1, col2] };

            expect(scope.headers).toEqual([]);

            tableController.addHeader(tableHead);
            expect(scope.headers).toEqual([{ columns: [col1, col2] }]);
        });

        it("should update the selected row count", function() {
            var row = { selected: true };

            tableController.itemSelected(row);

            expect(scope.table.numSelected).toEqual(1);
            expect(scope.table.allSelected()).toEqual(false);
        });

        it("should select all selectable rows", function() {
            tableController.selectAll(true);

            expect(scope.table.numSelected).toEqual(2);
            expect(scope.table.allSelected()).toEqual(true);
            expect(scope.table.rows[0].selected).toEqual(true);
        });

        it("should unselect all rows", function() {
            tableController.selectAll(false);

            expect(scope.table.numSelected).toEqual(0);
            expect(scope.table.allSelected()).toEqual(false);
            expect(scope.table.rows[0].selected).toEqual(false);
        });

        it("should set the chosen row", function() {
            var row = { id: 1 };

            tableController.itemChosen(row);

            expect(scope.table.chosenRow).toBe(row);
        });

        it("should disable select all", function() {
            tableController.disableSelectAll(true);

            expect(tableController.selection.selectAllDisabled).toBe(true);
        });

        it("should provide a method to check if all are selected", function() {
            scope.table.selectAll(true);
            expect(scope.table.allSelected()).toBe(true);
        });

    });

    describe('alchTable directive', function() {
        it("should have two columns including the row-select", function() {
            var columns = tableElement.find('thead').find('tr').find('th');

            expect(columns.length).toBe(2);
        });

        it('should have two rows', function() {
            var rows = tableElement.find('tbody').find('tr');

            expect(rows.length).toBe(scope.table.rows.length);
        });
    });

    describe('alchTableHead', function() {

        describe('directive', function() {
            describe('directive', function() {
                it("should select a table head row", function() {
                    var tableHead = angular.element(tableElement.find('thead').find('tr')[0]),
                        checkbox = tableHead.find('input[type="checkbox"]');

                    checkbox.trigger('click');
                    checkbox.attr('checked', 'checked');
                    checkbox.prop('checked', true);

                    expect(checkbox.is(':checked')).toBe(true);
                });
            });
        });

        describe('controller', function() {
            var element,
                tableHeadController;

            beforeEach(inject(function($controller) {
                tableController = $controller('AlchTableHeadController', {$scope: scope});
            }));

            it("should append a column", function() {
                var col1 = {};

                expect(scope.header.columns).toEqual([]);

                tableController.addColumn(col1);
                expect(scope.header.columns).toEqual([col1]);
            });
        });
    });

    describe('alchTableRow', function() {

        describe('directive', function() {
            it("should select a row and add 'selected-row' class", function() {
                var row = angular.element(tableElement.find('tbody').find('tr')[0]),
                    checkbox = row.find('.row-select').find('input');

                checkbox.trigger('click');
                checkbox.attr('checked', 'checked');
                checkbox.prop('checked', true);

                expect(checkbox.is(':checked')).toBe(true);
                expect(row.hasClass('selected-row')).toBe(true);
            });

            it("should choose a row and add 'selected-row' class", function() {
                var row = angular.element(chooseTableElement.find('tbody').find('tr')[0]),
                    radio = row.find('.row-choice').find('input');

                radio.trigger('click');

                expect(row.hasClass('selected-row')).toBe(true);
            });

            it("should only allow one row to be selected at a time", function() {
                var radios = angular.element(chooseTableElement.find('input'));


                angular.element(radios[0]).trigger('click');
                angular.element(radios[1]).trigger('click');

                expect(chooseTableElement.find('.selected-row').length).toBe(1);
            });

            it("should set a row as active and add 'active-row' class", function() {
                var cells = angular.element(angular.element(tableElement.find('tbody').find('tr')[0])).find('td');

                expect(cells.hasClass('active-row')).toBe(true);
            });
        });

        describe('controller', function() {
            var tableRowController;

            beforeEach(inject(function($controller) {
                tableRowController = $controller('AlchTableRowController', {$scope: scope});
            }));

            it("should append a cell", function() {
                var cell1 = {}, cell2 = {};

                expect(scope.row.cells).toEqual([]);

                tableRowController.addCell(cell1);
                tableRowController.addCell(cell2);

                expect(scope.row.cells).toEqual([cell1, cell2]);
            });
        });
    });

});
