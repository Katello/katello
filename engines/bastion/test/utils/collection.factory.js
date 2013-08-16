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

describe('Factory: Collection', function() {
    var $q;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function(_$q_, _Collection_) {
        $q = _$q_;
        Collection = _Collection_;
    }));

    describe("methods for interacting with a Katello API resource", function() {
        var collection,
            resource,
            data;

        beforeEach(function() {
            data = {
                total: 10,
                subtotal: 5,
                offset: 0
        
                records: [
                    { id: 1 },
                    { id: 2 },
                    { id: 3 },
                    { id: 4 },
                    { id: 5 }
                ]
            };

            resource = {
                get: function(params, callback) {
                    callback(data);
                }
            };

            collection = new Collection(resource);
        });

        it("should find an item in the records by ID", function() {
            collection.records = data.records;
            
            expect(collection.find(1)).toBe(data.records[0]);
        });

        it("should retrieve a single item from the provided resource object", function() {
            var item;

            collection.get({ id: 1 }).then(function(record) {
                item = record;
            });

            expect(item).toBe(data.records[0]);
        });

        it("should retrieve a collection of objects", function() {
            collection.get();

            expect(collection.records).toBe(data.records);
        });

    });

});

