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

describe('Factory: Provider', function() {
    var $httpBackend,
        providers;

    beforeEach(module('Bastion.providers'));

    beforeEach(module(function($provide) {
        providers = {
            records: [
                { name: 'Provider1', id: 1 },
                { name: 'Provider2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Provider = $injector.get('Provider');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of providers', function() {
        $httpBackend.expectGET('/katello/api/providers?organization_id=ACME&provider_type=Custom').respond(providers);

        Provider.query({ organization_id: 'ACME' }, function(providers) {
            expect(providers.records.length).toBe(2);
        });
    });

    it('provides a way to update a provider', function() {
        var provider = providers.records[0];

        provider['repository_url'] = 'http://wikipedia.org';
        $httpBackend.expectPUT('/katello/api/providers/1').respond(provider);

        Provider.update({'repository_url': 'http://wikipedia.org', id: 1}, function(record) {
            expect(record).toBeDefined();
            expect(record.repository_url).toBe('http://wikipedia.org');
        });
    });

    it('provides a way to refresh a manifest', function() {
        var provider = providers.records[0];

        $httpBackend.expectPOST('/katello/api/providers/1/refresh_manifest').respond(provider);

        Provider.refreshManifest({ organization_id: 'ACME', id: provider.id }, function(record) {
            expect(record.id).toBe(provider.id);
        });
    });

    it('provides a way to delete a manifest', function() {
        var provider = providers.records[0];

        $httpBackend.expectPOST('/katello/api/providers/1/delete_manifest').respond(provider);

        Provider.deleteManifest({ organization_id: 'ACME', id: provider.id }, function(record) {
            expect(record.id).toBe(provider.id);
        });
    });

});

