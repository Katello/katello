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
 **/

/**
 * @ngdoc service
 * @name  Katello.systems.factory:System
 *
 * @requires $resource
 * @requires Routes
 *
 * @description
 *   Provides a $resource for system or list of systems.
 */
angular.module('Bastion.systems').factory('System',
    ['$resource', 'Routes',
    function($resource, Routes) {
        var Collection = {},
            resource,
            updateCounts,
            findIndex,
            replaceInCollection;

        Collection.records  = [];
        Collection.offset   = 0;
        Collection.total    = 0;
        Collection.subtotal = 0;

        Collection.get = function(args, callback) {
            args = args || {};
            callback = callback || function() {};

            if (args['id']) {
                resource.get(args, function(record) {
                    replaceInCollection(record);
                    callback();
                });
            } else {
                if (args['offset'] === 0) {
                    Collection.offset = 0;
                } else {
                    Collection.offset = args['offset'];
                }

                resource.query(args, function(data) {
                    if (Collection.offset === 0) {
                        Collection.records = data.records;
                    } else {
                        Collection.records = Collection.records.concat(data.records);
                    }

                    Collection.offset = Collection.records.length;
                    Collection.total = data.total;
                    Collection.subtotal = data.subtotal;

                    callback();
                });
            }
        };

        resource = $resource(Routes.apiSystemsPath() + '/:systemId', {systemId: '@uuid'}, {
            update: { method: 'PUT'},
            query: { method: 'GET', isArray: false}
        });

        findIndex = function(record) {
            var index;

            angular.forEach(Collection.records, function(item, itemIndex) {
                if (item.id === record.id) {
                    index = itemIndex;
                }
            });

            return index;
        };

        replaceInCollection = function(record) {
            var index = findIndex(record);

            if (index) {
                Collection.records[index] = record;
            } else {
                Collection.records.push(record);
                updateCounts(1);
            }
        };

        updateCounts = function(count) {
            Collection.offset += count;
            Collection.total  += count;
            Collection.subtotal += count;
        };

        return Collection;
    }]
);
