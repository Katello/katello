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

describe('Factory: Nutupane', function() {
    var $timeout,
        $location,
        Resource,
        expectedResult,
        Nutupane;

    beforeEach(module('Bastion.widgets'));

    beforeEach(module(function() {
        expectedResult = [{id: 2, value: "value2"}, {id:3, value: "value3"}];
        Resource = {
            query: function(params, callback) {
                var result = {results: expectedResult};
                if (callback) {
                    callback(result);
                }
                return result;
            },
            customAction: function() {},
            total: 10,
            subtotal: 8,
            offset: 5,
            sort: {
                by: "description",
                order: "ASC"
            }
        };
    }));

    beforeEach(inject(function(_$location_, _$timeout_, _Nutupane_) {
        $location = _$location_;
        $timeout = _$timeout_;
        Nutupane = _Nutupane_;
    }));

    describe("adds additional functionality to the Nutupane table by", function() {
        var nutupane;

        beforeEach(function() {
            nutupane = new Nutupane(Resource);
            nutupane.table.working = false;
            nutupane.table.selectAll = function() {};
            nutupane.table.getSelected = function() {};
            nutupane.table.rows = [{id: 0, value: "value0"}, {id:1, value: "value1"}];
            nutupane.table.resource = Resource;
        });

        it("providing a method to fetch records for the table", function() {
            var expected = nutupane.table.rows.concat(expectedResult);

            spyOn(Resource, 'query').andCallThrough();
            nutupane.query();

            expect(Resource.query).toHaveBeenCalled();
            expect(nutupane.table.rows.length).toBe(4);
            angular.forEach(nutupane.table.rows, function(value, index) {
                expect(value).toBe(expected[index]);
            });
        });

        it("providing a method to refresh the table", function() {
            spyOn(Resource, 'query').andCallThrough();
            nutupane.refresh();

            expect(Resource.query).toHaveBeenCalled();
            expect(nutupane.table.rows).toBe(expectedResult);
        });

        it("providing a method to perform a search", function() {
            spyOn(Resource, 'query');
            nutupane.table.closeItem = function() {};

            nutupane.table.search();

            expect(Resource.query).toHaveBeenCalled();
        });

        it("refusing to perform a search if the table is currently fetching", function() {
            spyOn(Resource, 'query');
            nutupane.table.closeItem = function() {};
            nutupane.table.working = true;

            nutupane.table.search();

            expect(Resource.query).not.toHaveBeenCalled();
        });

        it("setting the search parameter in the URL when performing a search", function() {
            spyOn(Resource, 'query');
            nutupane.table.closeItem = function() {};
            nutupane.table.working = true;

            nutupane.table.search("Find Me");

            expect($location.search().search).toEqual("Find Me");
        });

        it("enforcing the user of this factory to define a closeItem function", function() {
            expect(nutupane.table.closeItem).toThrow();
        });

        it("updates a single occurrence of a row within the list of rows.", function() {
            var newRow = {id:0, value:"new value", anotherValue: "value"};
            nutupane.query();
            nutupane.table.replaceRow(newRow);
            expect(nutupane.table.rows[0]).toBe(newRow);
        });

        it("removes a single occurrence of a row within the list of rows.", function() {
            var row = {id:0, value: "value2"};
            nutupane.removeRow(row.id);
            expect(nutupane.table.rows.length).toBe(1);
            expect(nutupane.table.rows).not.toContain(row);
        });

        it("decrements num selected if removed row is selected.", function() {
               var row = nutupane.table.rows[0];
               row.selected = true;
               nutupane.table.numSelected = 1;

               nutupane.removeRow(row.id);
               expect(nutupane.table.rows.length).toBe(1);
               expect(nutupane.table.rows).not.toContain(row);
               expect(nutupane.table.numSelected).toBe(0);
        });

        it("providing a method that fetches more data", function() {
            nutupane.table.rows = [];
            spyOn(Resource, 'query');

            nutupane.table.nextPage();

            expect(Resource.query).toHaveBeenCalled();
        });

        it("refusing to fetch more data if the table is currently working", function() {
            spyOn(Resource, 'query');
            nutupane.table.working = true;
            nutupane.table.nextPage();

            expect(Resource.query).not.toHaveBeenCalled();
        });

        it("refusing to fetch more data if the subtotal of records equals the number of rows", function() {
            spyOn(Resource, 'query');
            nutupane.table.rows = new Array(8);
            nutupane.table.nextPage();

            expect(Resource.query).not.toHaveBeenCalled();
        });

        it("provides a way to add an individual row", function() {
            nutupane.table.rows = new Array(8);
            nutupane.table.addRow('');

            expect(nutupane.table.rows.length).toBe(9);
        });

        it("provides a way to enable select all results", function(){
           nutupane.enableSelectAllResults();
           expect(nutupane.table.selectAllResultsEnabled).toBe(true);
        });

        it("provides a way to select all results", function() {
            nutupane.enableSelectAllResults();
            spyOn(nutupane.table, 'selectAll');

            nutupane.table.selectAllResults(true);

            expect(nutupane.table.selectAll).toHaveBeenCalledWith(true);
            expect(nutupane.table.selectAllDisabled).toBe(true);
            expect(nutupane.table.allResultsSelected).toBe(true);
            expect(nutupane.table.numSelected).toBe(nutupane.table.resource.subtotal);
        });

        it("provides a way to de-select all results", function(){
            nutupane.enableSelectAllResults();
            nutupane.table.numSelected = 0;
            spyOn(nutupane.table, 'selectAll');
            nutupane.table.selectAllResults(false);

            expect(nutupane.table.selectAll).toHaveBeenCalledWith(false);
            expect(nutupane.table.selectAllDisabled).toBe(false);
            expect(nutupane.table.allResultsSelected).toBe(false);
            expect(nutupane.table.numSelected).toBe(0);
        });

        it("provides a way to get deselected items", function(){
            var deselected;
            nutupane.enableSelectAllResults();
            nutupane.table.rows = expectedResult;
            angular.forEach(nutupane.table.rows, function(item, itemIndex) {
                item.selected = true;
            });
            nutupane.table.rows[0].selected = false
            deselected = nutupane.getDeselected();

            expect(deselected.length).toBe(1);
            expect(deselected[0]).toBe(nutupane.table.rows[0]);
        });

        it("provides a way to retrieve selected result items", function(){
            var results;
            nutupane.enableSelectAllResults();
            nutupane.table.selectAllResults(true);
            nutupane.table.searchTerm = "FOO"

            angular.forEach(nutupane.table.rows, function(item, itemIndex) {
                item.selected = true;
            });
            nutupane.table.rows[0].selected = false;
            results = nutupane.getAllSelectedResults('id');
            expect(results.excluded.ids[0]).toBe(nutupane.table.rows[0]['id']);
            expect(results.included.search).toBe("FOO");
        });

        describe("provides a way to sort the table", function() {
            it ("defaults the sort to ascending if the previous sort does not match the new sort.", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'ASC', search: '', page: 1};
                nutupane.table.resource.sort = {};

                spyOn(Resource, 'query');
                nutupane.table.sortBy({id: "name"});

                expect(Resource.query).toHaveBeenCalledWith(expectedParams, jasmine.any(Function));
            });

            it("toggles the sort order if already sorting by that column", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'DESC', search: '', page: 1};
                nutupane.table.resource.sort = {
                    by: 'name',
                    order: 'ASC'
                };

                spyOn(Resource, 'query');
                nutupane.table.sortBy({id: "name"});

                expect(Resource.query).toHaveBeenCalledWith(expectedParams, jasmine.any(Function));
            });

            it("sets the column sort order and marks it as active.", function() {
                var column = {id: "name"}
                nutupane.table.resource.sort = {};
                nutupane.table.sortBy(column);
                expect(column.sortOrder).toBe("ASC");
                expect(column.active).toBe(true);
            });

            it("refreshes the table by calling query()", function() {
                spyOn(nutupane, "query");
                nutupane.table.sortBy({id: "name"});
                expect(nutupane.query).toHaveBeenCalled();
            });
        });
    });

    describe("recognizes custom actions by", function() {
        beforeEach(function() {
            nutupane = new Nutupane(Resource, {}, 'customAction');
            nutupane.table.working = false;
        });

        it("providing a method to fetch records for the table", function() {
            spyOn(Resource, 'customAction');
            nutupane.query();

            expect(Resource.customAction).toHaveBeenCalled();
        });
    });

});

