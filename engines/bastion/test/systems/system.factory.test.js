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
 **/

describe('Factory: System', function() {
    var System,
        releaseVersions,
        availableSubscriptions,
        systemsCollection;

    beforeEach(module('Bastion.systems', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        systemsCollection = {
            results: [
                { name: 'System1', id: 1 },
                { name: 'System2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        releaseVersions = ['RHEL 6', 'Burrito'];
        availableSubscriptions = ['subscription1', 'subscription2'];

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_System_) {
        System = _System_;
    }));

    it("provides a way to update a system", function() {
        var system = systemsCollection.results[0];
        system.name = 'NewSystemName';
        $httpBackend.expectPUT('/api/systems').respond(system);

        System.update({name: 'NewSystemName', id: 1}, function (system) {
            expect(system.name).toEqual('NewSystemName');
        });
    });

    it("provides a way to get the possible release versions for a system", function() {
        $httpBackend.expectGET('/api/systems').respond(systemsCollection.results[0]);

        System.releaseVersions({ id: systemsCollection.results[0].id }, function (data) {
            expect(data).toEqual(releaseVersions);
        });
    });

    it("provides a way to get the available subscriptions for a system", function() {
        $httpBackend.expectGET('/api/systems').respond(availableSubscriptions);

        System.subscriptions({ id: systemsCollection.results[0].id }, function (data) {
            expect(data).toEqual(availableSubscriptions);
        });
    });
});

