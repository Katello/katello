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
    });

    it('provides a way to get a list of providers', function() {
        $httpBackend.expectGET('/katello/api/providers?organization_id=ACME').respond(providers);

        Provider.query({ organization_id: 'ACME' }, function(providers) {
            expect(providers.records.length).toBe(2);
        });
    });

});

