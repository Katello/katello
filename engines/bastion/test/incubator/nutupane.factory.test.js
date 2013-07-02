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
        CurrentOrganization,
        Resource,
        Nutupane;

    beforeEach(module('Bastion.widgets'));

    beforeEach(module(function($provide) {
        Resource = {
            get: function(params, callback) {
                callback();
            },
            total: 10,
            subtotal: 8,
            offset: 5
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_$location_, _$timeout_, _Nutupane_) {
        $location = _$location_;
        $timeout = _$timeout_;
        Nutupane = _Nutupane_;
    }));

    describe("adds addiontional functionality to the Nutupane table by", function() {
        var nutupane;

        beforeEach(function() {
            nutupane = new Nutupane(Resource);
            nutupane.table.working = false;
        });

        it("providing a method to fetch records for the table", function() {
            spyOn(Resource, 'get');
            nutupane.get();

            expect(Resource.get).toHaveBeenCalled();
        });

        it("providing a method to perform a search", function() {
            spyOn(Resource, 'get');
            nutupane.table.closeItem = function() {};

            nutupane.table.search();

            expect(Resource.get).toHaveBeenCalled();
        });

        it("refusing to perform a search if the table is currently fetching", function() {
            spyOn(Resource, 'get');
            nutupane.table.closeItem = function() {};
            nutupane.table.working = true;

            nutupane.table.search();

            expect(Resource.get).not.toHaveBeenCalled();
        });

        it("setting the search parameter in the URL when performing a search", function() {
            spyOn(Resource, 'get');
            nutupane.table.closeItem = function() {};
            nutupane.table.working = true;

            nutupane.table.search("Find Me");

            expect($location.search().search).toEqual("Find Me");
        });

        it("enforcing the user of this factory to define a closeItem function", function() {
            expect(nutupane.table.closeItem).toThrow();
        });

        it("providing a method that fetches more data", function() {
            spyOn(Resource, 'get');
            nutupane.table.nextPage();

            expect(Resource.get).toHaveBeenCalled();
        });

        it("refusing to fetch more data if the table is currently working", function() {
            spyOn(Resource, 'get');
            nutupane.table.working = true;
            nutupane.table.nextPage();

            expect(Resource.get).not.toHaveBeenCalled();
        });

        it("refusing to fetch more data if the subtotal of records equals the offset", function() {
            spyOn(Resource, 'get');
            nutupane.table.resource.offset = 8;
            nutupane.table.nextPage();

            expect(Resource.get).not.toHaveBeenCalled();
        });
    });

});

