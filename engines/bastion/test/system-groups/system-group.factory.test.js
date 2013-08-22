/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Factory: SystemGroup', function() {
    var systemGroupFactory, $httpBackend, Routes, systemGroups;

    beforeEach(module('Bastion.system-groups'));

    beforeEach(function() {
        systemGroups = [{id: 0, name: "booyah"}, {id: 1, name: 'lalala'}, {id: 2, name: 'yesssir'}];

        module(function($provide) {
            Routes = {
                apiOrganizationSystemGroupsPath: function() { return "/api/system-groups"; }
            };
            $provide.value('Routes', Routes);
            $provide.value('CurrentOrganization', 'ACME');
        });

        inject(function($injector) {
            $httpBackend = $injector.get('$httpBackend');
            systemGroupFactory = $injector.get('SystemGroup');
        });
    });

    afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('makes a request to get the system group list from the API.', function() {
        $httpBackend.expectGET('/api/system-groups').respond(systemGroups);
        systemGroupFactory.query(function(response) {
            expect(response.length).toBe(systemGroups.length);

            for (var i = 0; i < systemGroups.length; i++) {
                expect(response[i].id).toBe(systemGroups[i].id);
                expect(response[i].name).toBe(systemGroups[i].name);
            }
        });
        $httpBackend.flush();
    });
});

