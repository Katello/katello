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

describe('Factory: GPGKey', function() {
    var $httpBackend,
        gpgKeys;

    beforeEach(module('Bastion.gpg-keys'));

    beforeEach(module(function($provide) {
        gpgKeys = {
            records: [
                { name: 'GPGKey1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        GPGKey = $injector.get('GPGKey');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositorys', function() {
        $httpBackend.expectGET('/api/v2/gpg_keys?organization_id=ACME').respond(gpgKeys);

        GPGKey.query(function(gpgKeys) {
            expect(gpgKeys.records.length).toBe(1);
        });
    });

});
