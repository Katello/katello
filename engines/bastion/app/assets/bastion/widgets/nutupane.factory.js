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
 * @requires CurrentOrganization
 *
 * @description
 *   Defines the Nutupane factory for adding common functionality to the Nutupane master-detail
 *   pattern.
 *
 * @example
 *   <pre>
       angular.module('example').controller('ExampleController',
           ['Nutupane', function(Nutupane)) {
               var nutupane                = new Nutupane();
               $scope.table                = nutupane.table;
           }]
       );
    </pre>
 */
angular.module('Bastion.widgets').factory('Nutupane',
    ['$location', '$q', '$timeout', 'CurrentOrganization',
    function($location, $q, $timeout, CurrentOrganization) {
        var Nutupane = function(resource) {
            var self = this;

            self.table = {
                resource: resource,
                searchString: $location.search().search,
                sort: {
                    by: 'name',
                    order: 'ASC'
                }
            };

            self.get = function() {
                var params = {
                    'organization_id':  CurrentOrganization,
                    'search':           $location.search().search || "",
                    'sort_by':          self.table.sort.by,
                    'sort_order':       self.table.sort.order,
                    'paged':            true,
                    'offset':           self.table.resource.offset
                };

                self.table.working = true;
                var deferred = $q.defer();
                self.table.resource.get(params, function(resource) {
                    // This $timeout is necessary to cause a $digest cycle for displaying
                    $timeout(function() {
                        deferred.resolve(resource);
                    }, 0);
                    self.table.working = false;
                });
                return deferred.promise;
            };

            self.table.search = function(searchTerm) {
                $location.search('search', searchTerm);
                self.table.resource.offset = 0;
                self.table.closeItem();

                if (!self.table.working) {
                    self.get();
                }
            };

            // Must be overridden
            self.table.closeItem = function() {
                throw "NotImplementedError";
            };

            self.table.nextPage = function() {
                var table = self.table;
                if (table.working || (table.resource.offset > 0 && table.hasMore())) {
                    return;
                }
                return self.get();
            };

            self.table.hasMore = function() {
                return self.table.resource.subtotal === self.table.resource.offset;
            };

            self.table.sortBy = function(column) {
                var sort = self.table.sort;
                if (column.id === sort.by) {
                    sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
                } else {
                    sort.order = 'ASC';
                    sort.by = column.id;
                }

                column.sortOrder = sort.order;
                column.active = true;
                self.table.resource.offset = 0;
                self.get();
            };
        };

        return Nutupane;
    }]
);
