/**
 Copyright 2014 Red Hat, Inc.

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
    var SystemGroup, $httpBackend, systemGroups;

    beforeEach(module('Bastion.system-groups', 'Bastion.test-mocks'));

    beforeEach(function() {
        systemGroups = {
            results: [{id: 0, name: "booyah"}, {id: 1, name: 'lalala'}, {id: 2, name: 'yesssir'}]
        };
    });

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SystemGroup = $injector.get('SystemGroup');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('makes a request to get the system group list from the API.', function() {
        $httpBackend.expectGET('/api/system_groups').respond(systemGroups);

        SystemGroup.queryPaged(function(response) {
            expect(response.results.length).toBe(systemGroups.results.length);

            for (var i = 0; i < systemGroups.results.length; i++) {
                expect(response.results[i].id).toBe(systemGroups.results[i].id);
            }
        });
    });

    it('provides a way to update a group', function() {
        var group = systemGroups.results[0];

        group.name = 'NewRepositoryName';
        $httpBackend.expectPUT('/api/system_groups/0').respond(group);

        SystemGroup.update({name: group.name, id: 0}, function(response) {
            expect(response).toBeDefined();
            expect(response.name).toBe(group.name);
        });
    });

    it('provides a way to add content hosts', function() {
        var contentHosts = [{id: 1}, {id: 2}];
        $httpBackend.expectPUT('/api/system_groups/0/add_systems').respond(contentHosts);
        SystemGroup.addContentHosts({'system_group': {'system_ids': [1,2]} , id: 0}, function(response) {
            expect(response).toBeDefined();
            expect(response.length).toBe(contentHosts.length);
        });
    });

    it('provides a way to remove content hosts', function() {
        var contentHosts = [{id: 1}, {id: 2}];
        $httpBackend.expectPUT('/api/system_groups/0/remove_systems').respond(contentHosts);
        SystemGroup.removeContentHosts({'system_group': {'system_ids': [1,2]} , id: 0}, function(response) {
            expect(response).toBeDefined();
            expect(response.length).toBe(contentHosts.length);
        });
    });

    it('provides a way to list content hosts', function() {
        var contentHosts = {results: [{id: 1}, {id: 2}]};
        $httpBackend.expectGET('/api/system_groups/0/systems').respond(contentHosts);
        SystemGroup.contentHosts({id: 0}, function(response) {
            expect(response).toBeDefined();
            expect(response.length).toBe(contentHosts.length);
        });
    });

});

