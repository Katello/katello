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

describe('Factory: SyncPlan', function() {
    var $httpBackend,
        SyncPlan,
        syncPlans,
        products;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        syncPlans = {
            records: [
                { name: 'SyncPlan1', id: 1, products: [{id: 3, name: 'product1'}]},
                { name: 'SyncPlan2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        products = {
            records: [
                { name: 'SyncPlan1', id: 1 },
                { name: 'SyncPlan2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SyncPlan = $injector.get('SyncPlan');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of syncPlans', function() {
        $httpBackend.expectGET('/api/v2/organizations/ACME/sync_plans?full_result=true').respond(syncPlans);

        SyncPlan.query(function(syncPlans) {
            expect(syncPlans.records.length).toBe(2);
        });
    });

    it('provides a way to update a syncPlan', function() {
        var updatedSyncPlan = syncPlans.records[0];

        updatedSyncPlan.name = 'NewSyncPlanName';
        $httpBackend.expectPUT('/api/v2/organizations/ACME/sync_plans/1').respond(updatedSyncPlan);

        SyncPlan.update({ id: 1 }, function(syncPlan) {
            expect(syncPlan).toBeDefined();
            expect(syncPlan.name).toBe('NewSyncPlanName');
        });
    });

    it('provides a way to list the available products', function() {
        $httpBackend.expectGET('/api/v2/organizations/ACME/sync_plans/1/available_products').respond(products);
        SyncPlan.availableProducts({id: 1}, function(products) {
            expect(products).toBe(products);
        });
    });

    it('provides a way to add product(s) to a syncPlan', function() {
        $httpBackend.expectPUT('/api/v2/organizations/ACME/sync_plans/1/add_products').respond(products);
        SyncPlan.addProducts({id: 1});
    });

    it('provides a way to remove product(s) from a syncPlan', function() {
        $httpBackend.expectPUT('/api/v2/organizations/ACME/sync_plans/1/remove_products').respond(products);
        SyncPlan.removeProducts({id: 1});
    });

    it("provides a way to display the syncPlan's products", function() {
        $httpBackend.expectGET('/api/v2/organizations/ACME/sync_plans/1').respond(syncPlans.records[0]);
        SyncPlan.products({id: 1});
    });
});
