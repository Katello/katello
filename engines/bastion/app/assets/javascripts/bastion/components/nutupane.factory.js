/**
 * @ngdoc service
 * @name  Bastion.components.service:Nutupane
 *
 * @requires $location
 * @requires $q
 * @requires entriesPerPage
 * @requires TableCache
 * @requires Notification
 *
 * @description
 *   Defines the Nutupane factory for adding common functionality to the Nutupane master-detail
 *   pattern.  Note that the API Nutupane uses must provide a response of the following structure:
 *
 *   {
 *      page: 1,
 *      subtotal: 50,
 *      total: 100,
 *      results: [...]
 *   }
 *
 * @example
 *   <pre>
       angular.module('example').controller('ExampleController',
           ['Nutupane', function (Nutupane)) {
               var nutupane                = new Nutupane(ExampleResource);
               $scope.table                = nutupane.table;
           }]
       );
    </pre>
 */
angular.module('Bastion.components').factory('Nutupane',
    ['$location', '$q', '$stateParams', 'entriesPerPage', 'TableCache', 'Notification', function ($location, $q, $stateParams, entriesPerPage, TableCache, Notification) {
        var Nutupane = function (resource, params, action, nutupaneParams) {
            var self = this;

            function getTableName() {
                return $location.path().split('/').join('-').slice(1);
            }

            function setQueryStrings() {
                // Don't manipulate the query string for params of a modal view
                if (document.body.className.indexOf("modal-open") >= 0) {
                    return;
                }

                if (self.table.params.paged) {
                    $location.search("page", self.table.params.page).replace();
                    $location.search("per_page", self.table.params['per_page']).replace();
                }

                if (self.table.params.search) {
                    $location.search(self.searchKey, self.table.params.search).replace();
                }

                if (self.table.params.sort_by) {
                    $location.search("sortBy", self.table.params['sort_by']).replace();
                }

                if (self.table.params['sort_order']) {
                    $location.search("sortOrder", self.table.params['sort_order']).replace();
                }
            }

            params = params || {};
            params.paged = true;
            params.page = $location.search().page || 1;
            params['per_page'] = $location.search()['per_page'] || entriesPerPage;

            nutupaneParams = nutupaneParams || {};
            self.disableAutoLoad = nutupaneParams.disableAutoLoad || false;
            self.searchKey = action ? action + 'Search' : 'search';

            self.table = {
                action: action || 'queryPaged',
                params: params,
                resource: resource,
                rows: [],
                searchTerm: $stateParams[self.searchKey] || $location.search()[self.searchKey] || "",
                initialLoad: true
            };

            self.loadParamsFromExistingTable = function (existingTable) {
                _.extend(params, existingTable.params);
                if (!self.table.searchTerm) {
                    self.table.searchTerm = existingTable.searchTerm;
                }
            };

            self.load = function () {
                var deferred = $q.defer(),
                    resourceCall,
                    table = self.table,
                    existingTable = TableCache.getTable(getTableName());

                table.working = true;

                if (table.initialLoad) {
                    table.refreshing = true;
                    table.searchCompleted = false;
                }

                if (existingTable) {
                    self.loadParamsFromExistingTable(existingTable);
                }

                params.search = table.searchTerm || "";
                params.search = self.searchTransform(params.search);

                resourceCall = resource[table.action](params, function (response) {
                    if (response.error) {
                        Notification.setErrorMessage(response.error);
                    }

                    angular.forEach(response.results, function (row) {
                        row.selected = table.allResultsSelected;
                    });

                    table.rows = response.results;

                    table.resource.page = parseInt(response.page, 10);
                    params.page = table.params.page = parseInt(response.page, 10);

                    if (table.initialSelectAll) {
                        table.selectAll(true);
                        table.initialSelectAll = false;
                    }

                    deferred.resolve(response);
                    table.resource = response;
                    table.resource.page = parseInt(response.page, 10);

                    if (self.selectAllMode) {
                        table.selectAll(true);
                    }

                    if (table.resource.page > 1) {
                        table.resource.offset = (table.resource.page - 1) * table.resource['per_page'] + 1;
                    } else {
                        table.resource.offset = 1;
                    }

                    TableCache.setTable(getTableName(), table);
                    setQueryStrings();

                    table.working = false;
                    table.refreshing = false;
                    table.initialLoad = false;
                });

                if (resourceCall && resourceCall.$promise && resourceCall.$promise.catch) {
                    resourceCall.$promise.catch(function () {
                        table.working = false;
                        table.refreshing = false;
                    });
                }

                return deferred.promise;
            };

            self.getParams = function () {
                return params;
            };

            self.table.autocomplete = function (term) {
                var data, promise, localParams;

                if (resource.autocomplete) {
                    localParams = self.getParams();
                    localParams.search = term;
                    data = resource.autocomplete(params);
                } else {
                    data = self.table.fetchAutocomplete(term);
                }

                promise = data.$promise;
                if (promise) {
                    return promise.then(function (response) {
                        return self.table.transformScopedSearch(response);
                    });
                }

                return data;
            };

            self.table.transformScopedSearch = function (results) {
                var rows = [],
                    categoriesFound = [];
                angular.forEach(results, function (row) {
                    if (row.category && row.category.length > 0) {
                        if (categoriesFound.indexOf(row.category) === -1) {
                            categoriesFound.push(row.category);
                            rows.push({category: row.category, isCategory: true});
                        }
                    }
                    rows.push(row);
                });

                return rows;
            };

            //Overridable by real controllers, but default to nothing
            self.table.fetchAutocomplete = function () {
                return [];
            };

            self.enableSelectAllResults = function () {
                self.table.selectAllResultsEnabled = true;
                self.table.allResultsSelected = false;
            };

            self.setParams = function (newParams) {
                params = newParams;
            };

            self.addParam = function (param, value) {
                params[param] = value;
            };

            self.searchTransform = function (term) {
                return term;
            };

            self.query = function () {
                var table = self.table;
                if (table.rows.length === 0) {
                    table.resource.page = 0;
                }
                return self.load();
            };

            self.refresh = function () {
                var promise, existingTable;
                existingTable = TableCache.getTable(getTableName());

                if (existingTable) {
                    self.loadParamsFromExistingTable(existingTable);
                }

                self.table.refreshing = true;
                self.table.numSelected = 0;
                promise = self.load();
                promise.then(function () {
                    self.table.selectAllResults(false);
                });
                return promise;
            };

            self.invalidate = function () {
                TableCache.removeTable(getTableName());
            };

            self.removeRow = function (id, field) {
                var foundItem, table = self.table;

                field = field || 'id';

                angular.forEach(table.rows, function (item) {
                    if (item[field] === id) {
                        foundItem = item;
                    }
                });

                table.rows = _.reject(table.rows, function (item) {
                    return item[field] === id;
                }, this);

                table.resource.total = table.resource.total - 1;
                table.resource.subtotal = table.resource.subtotal - 1;
                if (foundItem && foundItem.selected) {
                    table.numSelected = table.numSelected - 1;
                }

                return self.table.rows;
            };

            self.getAllSelectedResults = function (identifier) {
                var selected, selectedRows;
                identifier = identifier || 'id';
                selected = {
                    included: {
                        ids: [],
                        resources: [],
                        search: null,
                        params: params
                    },
                    excluded: {
                        ids: []
                    }
                };

                if (self.table.allResultsSelected) {
                    selected.included.search = self.table.searchTerm || '';
                    selected.excluded.ids = _.map(self.getDeselected(), identifier);
                } else {
                    selectedRows = self.table.getSelected();
                    selected.included.ids = _.map(selectedRows, identifier);
                    selected.included.resources = selectedRows;
                }
                return selected;
            };

            self.getDeselected = function () {
                var deselectedRows = [];
                angular.forEach(self.table.rows, function (row, rowIndex) {
                    if (row.selected !== true) {
                        deselectedRows.push(self.table.rows[rowIndex]);
                    }
                });
                return deselectedRows;
            };

            self.table.search = function (searchTerm) {
                $location.search(self.searchKey, searchTerm);
                self.table.searchTerm = searchTerm;
                self.table.resource.page = 1;
                self.table.params.page = 1;
                self.table.rows = [];
                self.table.selectAllResults(false);

                if (!self.table.working) {
                    self.table.refreshing = true;
                    if (searchTerm) {
                        self.table.searchCompleted = true;
                    } else {
                        self.table.searchCompleted = false;
                    }
                    self.query();
                }
            };

            self.table.clearSearch = function () {
                self.table.search(null);
                self.table.searchCompleted = true;
            };

            self.table.replaceRow = function (row) {
                var index, selected;
                index = null;
                angular.forEach(self.table.rows, function (item, itemIndex) {
                    if (item.id === row.id) {
                        index = itemIndex;
                        selected = item.selected;
                    }
                });

                if (index >= 0) {
                    row.selected = selected; //Preserve selectedness
                    self.table.rows[index] = row;
                }
            };

            self.table.addRow = function (row) {
                self.table.rows.unshift(row);
                self.table.resource.subtotal += 1;
                self.table.resource.total += 1;
            };

            self.table.hasPagination = function () {
                return self.table.resource && self.table.resource.subtotal && self.table.resource.page &&
                    self.table.resource.per_page && self.table.resource.offset;
            };

            self.table.onFirstPage = function () {
                return self.table.resource.page === 1;
            };

            self.table.getLastPage = function () {
                return Math.ceil(self.table.resource.subtotal / self.table.resource.per_page);
            };

            self.table.onLastPage = function () {
                return self.table.resource.page >= self.table.getLastPage();
            };

            self.table.pageExists = function (pageNumber) {
                return (pageNumber >= 1) && (pageNumber <= self.table.getLastPage());
            };

            self.table.getPageStart = function () {
                var table = self.table, pageStart = 0;

                if (table.rows.length > 0) {
                    pageStart = table.resource.offset;
                }

                return pageStart;
            };

            self.table.getPageEnd = function () {
                var table = self.table, pageEnd;

                pageEnd = table.resource.offset + table.rows.length - 1;

                if (pageEnd > table.resource.subtotal) {
                    pageEnd = table.resource.subtotal;
                }

                return pageEnd;
            };

            self.table.firstPage = function () {
                return self.table.changePage(1);
            };

            self.table.previousPage = function () {
                var previousPage = parseInt(params.page, 10) - 1;
                return self.table.changePage(previousPage);
            };

            self.table.nextPage = function () {
                var nextPage = parseInt(params.page, 10) + 1;
                return self.table.changePage(nextPage);
            };

            self.table.lastPage = function () {
                var table = self.table;
                return table.changePage(self.table.getLastPage());
            };

            self.table.changePage = function (pageNumber) {
                if (pageNumber && self.table.pageExists(pageNumber)) {
                    self.invalidate();
                    params.page = pageNumber;
                    self.table.resource.page = pageNumber;
                    return self.load();
                }
            };

            self.table.pageSizes = _.uniq(_([25, 50, 75, 100, entriesPerPage]).sortBy().value());

            self.table.updatePageSize = function () {
                params.page = 1;
                self.query();
            };

            // Wraps the table.selectAll() function if selectAllResultsEnabled is not set
            // Otherwise provides expanded functionality

            self.table.selectAllResults = function (selectAll) {
                if (self.table.allSelected() || selectAll !== 'undefined') {
                    self.table.selectAll(selectAll);
                } else if (selectAll) {
                    self.table.initialSelectAll = true;
                }

                if (self.table.selectAllResultsEnabled) {
                    if (selectAll) {
                        self.table.disableSelectAll();
                    } else {
                        self.table.enableSelectAll();
                    }

                    self.table.allResultsSelected = selectAll;
                    self.table.numSelected = selectAll ? self.table.resource.subtotal : 0;
                }
            };

            self.table.allResultsSelectCount = function () {
                return self.table.resource.subtotal - self.getDeselected().length;
            };

            self.table.sortBy = function (column) {
                if (!column) {
                    return;
                }
                if (column.id) {
                    params["sort_by"] = column.id;
                }
                if (column.id === params["sort_by"] || column.id) {
                    params["sort_order"] = (params["sort_order"] === 'ASC') ? 'DESC' : 'ASC';
                } else {
                    params["sort_order"] = 'ASC';
                }

                column.sortOrder = params["sort_order"];
                column.active = true;
                self.table.rows = [];
                self.query();
            };

            self.setSearchKey = function (newKey) {
                self.searchKey = newKey;
                self.table.searchTerm = $location.search()[self.searchKey];
            };

            if (!self.disableAutoLoad) {
                self.load();
            }
        };

        return Nutupane;
    }]
);
