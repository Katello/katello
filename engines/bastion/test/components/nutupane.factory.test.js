describe('Factory: Nutupane', function() {
    var $timeout,
        $location,
        $stateParams,
        $rootScope,
        $q,
        Resource,
        TableCache,
        Notification,
        entriesPerPage,
        expectedResult,
        Nutupane;

    beforeEach(module('Bastion.components'));

    beforeEach(module(function ($provide) {
        $stateParams = {};

        entriesPerPage = 20;

        TableCache = {
            getTable: function () {
            },
            setTable: function () {
            },
            removeTable: function () {
            }
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $provide.value('$stateParams', $stateParams);
        $provide.value('entriesPerPage', entriesPerPage);
        $provide.value('TableCache', TableCache);
        $provide.value('Notification', Notification);
    }));

    beforeEach(inject(function(_$location_, _$timeout_, _Nutupane_, _$rootScope_, _$q_) {
        $location = _$location_;
        $timeout = _$timeout_;
        Nutupane = _Nutupane_;
        $rootScope = _$rootScope_;
        $q = _$q_;

        expectedResult = [{id: 2, value: "value2"}, {id:3, value: "value3"},
            {id: 4, value: "value4"}, {id:5, value: "value5"}];
        Resource = {
            queryPaged: function(params, callback) {
                var result = {
                  page: 1,
                  results: expectedResult,
                  subtotal: 8,
                  per_page: 2,
                  $promise: $q.resolve()
                };
                if (callback) {
                    callback(result);
                }
                return result;
            },
            customAction: function(params, callback) {
                return {$promise: $q.resolve()};
            },
            page: 1,
            per_page: 2,
            total: 10,
            subtotal: 8,
            offset: 1,
            sort: {
                by: "description",
                order: "ASC"
            }
        };
    }));

    describe("adds additional functionality to the Nutupane table by", function() {
        var nutupane;

        beforeEach(function() {
            nutupane = new Nutupane(Resource);
            nutupane.table.working = false;
            nutupane.table.selectAll = function() {};
            nutupane.table.getSelected = function() {};
            nutupane.table.disableSelectAll = function () { };
            nutupane.table.enableSelectAll = function () { };
            nutupane.table.allSelected = function () { return true; };
            nutupane.table.rows = [{id: 0, value: "value0"}, {id:1, value: "value1"}];
            nutupane.table.resource = Resource;
        });

        it("providing a method to fetch records for the table", function() {
            spyOn(Resource, 'queryPaged').and.callThrough();
            nutupane.query();

            expect(Resource.queryPaged).toHaveBeenCalled();
            expect(nutupane.table.rows.length).toBe(4);
            angular.forEach(nutupane.table.rows, function(value, index) {
                expect(value).toBe(expectedResult[index]);
            });
        });

        describe("sets query string params of the table's properties", function () {
            beforeEach(function () {
                spyOn($location, 'search').and.callThrough();
            });

            it("if paged", function () {
                nutupane.table.params.paged = true;
                nutupane.load();
                expect($location.search).toHaveBeenCalledWith('page', 1);
                expect($location.search).toHaveBeenCalledWith('per_page', 20);
            });

            it("from existing table", function () {
                table = {params: {per_page: 30}};
                expect(nutupane.table.params.per_page).toBe(20);
                nutupane.loadParamsFromExistingTable(table);
                expect(nutupane.table.params.per_page).toBe(30);
            });

            it("but does not include page information if not paged", function () {
                nutupane.table.params.paged = false;
                nutupane.load();
                expect($location.search).not.toHaveBeenCalledWith('page', jasmine.any);
                expect($location.search).not.toHaveBeenCalledWith('per_page', jasmine.any);
            });

            it("by including a search if there is one", function () {
                nutupane.table.searchTerm = 'hello!';
                nutupane.load();
                expect($location.search).toHaveBeenCalledWith('search', 'hello!');
            });

            it("by not including a search if there isn't one", function () {
                nutupane.load();
                expect($location.search).not.toHaveBeenCalledWith('search', jasmine.any);
            });

            it("by including the sort properties if provided", function () {
                nutupane.table.params['sort_by'] = 'name';
                nutupane.table.params['sort_order'] = 'asc';
                nutupane.load();
                expect($location.search).toHaveBeenCalledWith('sortBy', 'name');
                expect($location.search).toHaveBeenCalledWith('sortOrder', 'asc');
            });

            it("by not including the sort properties if provided", function () {
                nutupane.load();
                expect($location.search).not.toHaveBeenCalledWith('sortBy', jasmine.any);
                expect($location.search).not.toHaveBeenCalledWith('sortOrder', jasmine.any);
            });
        });

        it("providing a method to refresh the table", function() {
            spyOn(Resource, 'queryPaged').and.callThrough();

            nutupane.refresh();

            expect(Resource.queryPaged).toHaveBeenCalled();
            expect(nutupane.table.rows).toBe(expectedResult);
        });

        it("provides a way to invalidate the table", function () {
            spyOn(TableCache, 'removeTable');
            nutupane.invalidate();
            expect(TableCache.removeTable).toHaveBeenCalled();
        });

        it("providing a method to perform a search", function() {
            spyOn(Resource, 'queryPaged').and.callThrough();

            nutupane.table.search();

            expect(Resource.queryPaged).toHaveBeenCalled();
        });

        it("refusing to perform a search if the table is currently fetching", function() {
            spyOn(Resource, 'queryPaged');
            nutupane.table.working = true;

            nutupane.table.search();

            expect(Resource.queryPaged).not.toHaveBeenCalled();
        });

        it("setting the search parameter in the URL when performing a search", function() {
            spyOn(Resource, 'queryPaged');

            nutupane.table.working = true;

            nutupane.table.search("Find Me");

            expect($location.search().search).toEqual("Find Me");
        });

        it("can clear the search", function () {
            spyOn(nutupane.table, 'search');

            nutupane.table.clearSearch();

            expect(nutupane.table.search).toHaveBeenCalledWith(null);
            expect(nutupane.table.searchCompleted).toBe(true);
        });

        it("updates a single occurrence of a row within the list of rows.", function() {
            var newRow = {id:0, value:"new value", anotherValue: "value"};
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

        it("provides a way to check if the table supports pagination", function () {
            expect(nutupane.table.hasPagination()).toBeTruthy();
            nutupane.table.resource.subtotal = null;
            expect(nutupane.table.hasPagination()).toBeFalsy();
        });

        it("provides a way to tell if on the first page", function () {
            nutupane.table.firstPage();
            expect(nutupane.table.onFirstPage()).toBe(true);
        });

        it("provides a way to get the last page", function () {
            expect(nutupane.table.getLastPage()).toBe(4);
        });

        it("provides a way to tell if on the last page", function () {
            spyOn(nutupane, 'load');
            nutupane.table.lastPage();
            expect(nutupane.table.onLastPage()).toBe(true);
            expect(nutupane.load).toHaveBeenCalled();
        });

        it("provides a way to see if a page exists", function () {
            expect(nutupane.table.pageExists(2)).toBe(true);
            expect(nutupane.table.pageExists(4)).toBe(true);
            expect(nutupane.table.pageExists(23524)).toBe(false);
        });

        it("provides a way to get the page start based on offset", function () {
            expect(nutupane.table.getPageStart()).toBe(1);
            nutupane.table.rows = [];
            expect(nutupane.table.getPageStart()).toBe(0);
        });

        it("provides a way to get the page end based on offset", function () {
            expect(nutupane.table.getPageEnd()).toBe(2);
        });

        describe("provides page navigation", function () {
            beforeEach(function () {
                spyOn(nutupane.table, 'changePage').and.callThrough();
                spyOn(nutupane, 'load');
            });

            afterEach(function () {
                expect(nutupane.load).toHaveBeenCalled();
            });

            it("to the first page", function () {
                nutupane.table.firstPage();
                expect(nutupane.table.changePage).toHaveBeenCalledWith(1);
            });

            it("to the previous page", function () {
                nutupane.table.params.page = 3;
                nutupane.table.previousPage();
                expect(nutupane.table.changePage).toHaveBeenCalledWith(2);
            });

            it("to the next page", function () {
                nutupane.table.params.page = 3;
                nutupane.table.nextPage();
                expect(nutupane.table.changePage).toHaveBeenCalledWith(4);
            });

            it("to the last page", function () {
                nutupane.table.lastPage();
                expect(nutupane.table.changePage).toHaveBeenCalledWith(4);
            });

            it("to an arbitrary page", function () {
                nutupane.table.changePage(3);
                expect(nutupane.table.resource.page).toBe(3);
                expect(nutupane.table.params.page).toBe(3);
            });
        });

        it("sets the array of page sizes that includes the default setting from rails", function () {
            expect(nutupane.table.pageSizes).toBeDefined();
            expect(nutupane.table.pageSizes).toContain(entriesPerPage);
        });

        it("provides a way to update the page size", function () {
            spyOn(nutupane, "query");
            nutupane.table.updatePageSize();
            expect(nutupane.query).toHaveBeenCalled();
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
            spyOn(nutupane.table, 'disableSelectAll');

            nutupane.table.selectAllResults(true);

            expect(nutupane.table.selectAll).toHaveBeenCalledWith(true);
            expect(nutupane.table.disableSelectAll).toHaveBeenCalled();
            expect(nutupane.table.allResultsSelected).toBe(true);
            expect(nutupane.table.numSelected).toBe(nutupane.table.resource.subtotal);
        });

        it("provides a way to de-select all results", function(){
            nutupane.enableSelectAllResults();
            nutupane.table.numSelected = 0;
            spyOn(nutupane.table, 'selectAll');
            spyOn(nutupane.table, 'enableSelectAll');
            nutupane.table.selectAllResults(false);

            expect(nutupane.table.selectAll).toHaveBeenCalledWith(false);
            expect(nutupane.table.enableSelectAll).toHaveBeenCalled();
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

        it("provides a way to translate scoped search queries", function() {
            var translated,
                data = [{label: 'bar', category: 'foo'},
                        {label: 'bar2', category: 'foo'}];

            translated = nutupane.table.transformScopedSearch(data);
            expect(translated.length).toBe(3);
            expect(translated[0].isCategory).toBeTruthy();
            expect(translated[0].category).toBe('foo');
            expect(translated[1]).toBe(data[0]);
            expect(translated[2]).toBe(data[1]);
        });

        it("provides a way to change the searchKey", function() {
            nutupane.setSearchKey("keyFoo");
            expect(nutupane.searchKey).toBe("keyFoo");
        });

        it("autocompletes using the original resource if possible", function() {
            var data;
            Resource.autocomplete = function() {return ["foo"]};
            spyOn(Resource, 'autocomplete').and.callThrough();

            data = nutupane.table.autocomplete();
            expect(Resource.autocomplete).toHaveBeenCalled();
            expect(data[0]).toBe("foo");
        });

        it("autocompletes using fetchAutocomplete if resource doesn't support autocomplete", function() {
            var data;
            nutupane.table.fetchAutocomplete = function() {return ['bar']};
            spyOn(nutupane.table, 'fetchAutocomplete').and.callThrough();

            data = nutupane.table.autocomplete();
            expect(nutupane.table.fetchAutocomplete).toHaveBeenCalled();
            expect(data[0]).toBe("bar");
        });

        describe("provides a way to sort the table", function() {
            it("defaults the sort to ascending if the previous sort does not match the new sort.", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'ASC', search: '', paged: true, page: 1, per_page: entriesPerPage};
                nutupane.table.resource.sort = {};

                spyOn(Resource, 'queryPaged').and.callThrough();
                nutupane.table.sortBy({id: "name"});

                expect(Resource.queryPaged).toHaveBeenCalledWith(expectedParams, jasmine.any(Function));
            });

            it("toggles the sort order if already sorting by that column", function() {
                var expectedParams = {sort_by: 'name', sort_order: 'DESC', search: '', paged: true, page: 1, per_page: entriesPerPage};
                nutupane.table.params["sort_by"] = 'name';
                nutupane.table.params["sort_order"] = 'ASC';

                spyOn(Resource, 'queryPaged').and.callThrough();
                nutupane.table.sortBy({id: "name"});

                expect(Resource.queryPaged).toHaveBeenCalledWith(expectedParams, jasmine.any(Function));
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

    describe("Nutupane should", function() {
        beforeEach(function() {
            nutupane = new Nutupane(Resource, {}, 'customAction');
            nutupane.table.working = false;
            nutupane.table.allSelected = function () {};
            nutupane.table.selectAll = function () {};
        });

        it("provide a method to fetch records for the table via a custom action", function() {
            spyOn(Resource, 'customAction').and.callThrough();
            nutupane.query();

            expect(Resource.customAction).toHaveBeenCalled();
        });

        it("naming the URL search field based off the action", function() {
            nutupane.table.search('*');

            expect($location.search()['customActionSearch']).toBe('*');
        });

        it("provide a method to add params", function () {
            nutupane.addParam('test', 'ABC');

            expect(nutupane.getParams()['test']).toBe('ABC');
        });

        it("be able to disable auto-load", function() {
            spyOn(Resource, 'customAction')
            nutupane = new Nutupane(Resource, {}, 'customAction', {'disableAutoLoad': true});
            expect(nutupane.disableAutoLoad).toBe(true);
            expect(Resource.customAction).not.toHaveBeenCalled();
        });

        it("be able to load results after initialization", function() {
            spyOn(Resource, 'customAction').and.callThrough();
            nutupane = new Nutupane(Resource, {}, 'customAction', {'disableAutoLoad': true});
            expect(nutupane.disableAutoLoad).toBe(true);
            nutupane.refresh();
            expect(Resource.customAction).toHaveBeenCalled();
        });

        it("be able to enable autoload", function() {
            spyOn(Resource, 'customAction').and.callThrough();
            nutupane = new Nutupane(Resource, {}, 'customAction', {'disableAutoLoad': false});
            expect(nutupane.disableAutoLoad).toBe(false);
            expect(Resource.customAction).toHaveBeenCalled();
        });

        describe("when there was an error loading the resource", function() {
            beforeEach(function() {
                spyOn(Resource, 'customAction').and.callFake(function() {
                      return {
                        $promise: $q.reject('internal server error')
                      };
                });
                nutupane.load();
                $rootScope.$apply();
            });

            it("ensures the table is not in 'refreshing' state", function() {
                expect(nutupane.table.refreshing).toBe(false);
            });

            it("ensures the table is not in 'working' state", function() {
                expect(nutupane.table.working).toBe(false);
            });
        });
    });
});

