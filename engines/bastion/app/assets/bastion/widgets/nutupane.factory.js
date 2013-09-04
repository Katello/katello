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

/**
 * @ngdoc service
 * @name  Bastion.widgets.service:Nutupane
 *
 * @requires $location
 * @requires $q
 * @requires $timeout
 *
 * @description
 *   Defines the Nutupane factory for adding common functionality to the Nutupane master-detail
 *   pattern.  Note that the API Nutupane uses must provide a response of the following structure:
 *
 *   {
 *      offset: 25,
 *      subtotal: 50,
 *      total: 100,
 *      results: [...]
 *   }
 *
 * @example
 *   <pre>
       angular.module('example').controller('ExampleController',
           ['Nutupane', function(Nutupane)) {
               var nutupane                = new Nutupane(ExampleResource);
               $scope.table                = nutupane.table;
           }]
       );
    </pre>
 */
angular.module('Bastion.widgets').factory('Nutupane',
    ['$location', '$q', '$timeout', function($location, $q, $timeout) {
        var Nutupane = function(resource, params, action) {
            var self = this;
            params = params || {};

            self.table = {
                action: action || 'query',
                params: params,
                resource: resource,
                rows: [],
                searchTerm: $location.search().search
            };

            // Set default resource values
            resource.offset = 0;
            resource.subtotal = "0";
            resource.total = "0";
            resource.results = [];

            self.query = function() {
                var deferred = $q.defer(), table = self.table;
                table.working = true;
                params.offset = table.rows.length;
                params.search = table.searchTerm || "";
                resource[table.action](params, function(response) {
                    table.rows = table.rows.concat(response.results);
                    // This $timeout is necessary to cause a digest cycle
                    // in order to prevent loading two sets of results.
                    $timeout(function() {
                        deferred.resolve(response);
                        table.resource = response;
                        table.resource.offset = table.rows.length;
                    }, 0);
                    table.working = false;
                });
                return deferred.promise;
            };

            self.removeRow = function(row) {
                var table = self.table;
                table.rows = _.reject(table.rows, function(item) {
                    return item.id === row.id;
                }, this);
                table.resource.total = table.resource.total - 1;
                table.resource.subtotal = table.resource.subtotal - 1;
                return self.table.rows;
            };

            self.table.search = function(searchTerm) {
                $location.search('search', searchTerm);
                self.table.resource.offset = 0;
                self.table.rows = [];
                self.table.closeItem();

                if (!self.table.working) {
                    self.query();
                }
            };

            // Must be overridden
            self.table.closeItem = function() {
                throw "NotImplementedError";
            };

            self.table.replaceRow = function(row) {
                var index = null;
                angular.forEach(self.table.rows, function(item, itemIndex) {
                    if (item.id === row.id) {
                        index = itemIndex;
                    }
                });

                if (index >= 0) {
                    self.table.rows[index] = row;
                }
            };

            self.table.addRow = function(row) {
                self.table.rows.unshift(row);
                self.table.resource.offset += 1;
                self.table.resource.subtotal += 1;
                self.table.resource.total += 1;
            };

            self.table.nextPage = function() {
                var table = self.table;
                if (table.working || !table.hasMore()) {
                    return;
                }
                return self.query();
            };

            self.table.hasMore = function() {
                var length = self.table.rows.length;
                var subtotal = self.table.resource.subtotal;
                return ((length === 0 && subtotal !== 0) || (length < subtotal));
            };

            self.table.sortBy = function(column) {
                var sort = self.table.resource.sort;
                if (!column) {
                    return;
                }

                params["sort_by"] = column.id;
                if (column.id === sort.by) {
                    params["sort_order"] = (sort.order === 'ASC') ? 'DESC' : 'ASC';
                } else {
                    params["sort_order"] = 'ASC';
                }

                column.sortOrder = params["sort_order"];
                column.active = true;
                self.table.rows = [];
                self.query();
            };
        };
        return Nutupane;
    }]
);
