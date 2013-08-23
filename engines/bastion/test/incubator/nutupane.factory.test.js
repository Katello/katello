/**
 * Copyright 2013 Red Hat, Inc.
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
        Nutupane;

    beforeEach(module('Bastion.widgets'));

    beforeEach(module(function() {
        Resource = {
            query: function(params, callback) {
                var result = {results: [{id: 1, value: "value"}, {id:2, value: "value2"}]};
                if (callback) {
                    callback(result);
                }
                return result;
            },
            customAction: function(){},
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
        });

        it("providing a method to fetch records for the table", function() {
            spyOn(Resource, 'query');
            nutupane.query();

            expect(Resource.query).toHaveBeenCalled();
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
            var newRow = {id:1, value:"new value", anotherValue: "value"};
            nutupane.query();
            nutupane.table.replaceRow(newRow);
            expect(nutupane.table.rows[0]).toBe(newRow);
        });

        it("providing a method that fetches more data", function() {
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

        describe("provides a way to sort the table", function(){
            it ("defaults the sort to ascending if the previous sort does not match the new sort.", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'ASC', offset: 0, search: ''};
                nutupane.table.resource.sort = {};

                spyOn(Resource, 'query');
                nutupane.table.sortBy({id: "name"});

                expect(Resource.query).toHaveBeenCalledWith(expectedParams, jasmine.any(Function));
            });

            it("toggles the sort order if already sorting by that column", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'DESC', offset: 0, search: ''};
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

