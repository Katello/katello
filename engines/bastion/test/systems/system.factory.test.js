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

describe('Factory: System', function() {
    var $resource,
        $q,
        Routes,
        releaseVersions,
        systemsCollection;

    beforeEach(module('Bastion.systems'));

    beforeEach(module(function($provide) {
        systemsCollection = {
            records: [
                { name: 'System1', id: 1 },
                { name: 'System2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        releaseVersions = ['RHEL 6', 'Burrito'];

        Routes = {
            apiSystemsPath: function() { return '/api/systems';},
            editSystemPath: function(id) { return '/system/' + id;}
        };

        $resource = function() {
            this.get = function(args, callback) {
                callback(systemsCollection.records[0]);
            };

            this.update = function() {};

            this.query = function(args, callback) {
                callback(systemsCollection);
            };

            this.releaseVersions = function(args, callback) {
                var deferred = $q.defer();

                deferred.resolve(releaseVersions);

                return deferred.promise;
            };

            return this;
        };

        $provide.value('$resource', $resource);
        $provide.value('Routes', Routes);
    }));

    beforeEach(inject(function(_System_, _$q_) {
        System = _System_;
        $q = _$q_;
    }));

    it("provides a way to get a collection of systems", function() {
        System.get();

        expect(System.records).toEqual(systemsCollection.records);
        expect(System.total).toEqual(systemsCollection.total);
        expect(System.subtotal).toEqual(systemsCollection.subtotal);
        expect(System.offset).toEqual(2);
    });

    it("provides a way to get a single system by the system ID", function() {
        System.get({ id: systemsCollection.records[0].id });

        expect(System.records).toEqual([systemsCollection.records[0]]);
        expect(System.total).toEqual(1);
        expect(System.subtotal).toEqual(1);
        expect(System.offset).toEqual(1);
    });

    it("updates a single system's occurence within the collection", function() {
        System.get();

        systemsCollection.records[1].name = 'NewSystemName';
        System.get({ id: systemsCollection.records[1].id });

        expect(System.records[1].name).toEqual('NewSystemName');
    });

    it("provides a way to get the possible release versions for a system via a promise", function() {
        var releasePromise = System.releaseVersions({ id: systemsCollection.records[0].id });

        releasePromise.then(function(data) {
            expect(data).toEqual(releaseVersions);
        });
    });
});

