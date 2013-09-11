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

describe('Factory: Organization', function() {
    var $httpBackend,
        task,
        Organization,
        organizations;

    beforeEach(module('Bastion.organizations'));

    beforeEach(module(function($provide) {
        var routes;

        organizations = {
            records: [
                { name: 'ACME', id: 1,
                  name: 'ECME', id: 2}
            ],
            total: 2,
            subtotal: 2
        };

        task = {id: 'task_id'};

        routes = {
            apiOrganizationsPath: function() {return '/katello/api/organizations'}
        };

        $provide.value('CurrentOrganization', 'ACME');
        $provide.value('Routes', routes);
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Organization = $injector.get('Organization');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way retrieve an organization', function() {
        $httpBackend.expectGET('/katello/api/organizations/ACME').respond(organizations);
        Organization.query(function(organizations) {
            expect(organizations.records.length).toBe(1);
        });
    });

    it('provides a way to auto attach available subscriptions to systems', function() {
        $httpBackend.expectPOST('/katello/api/organizations/ACME/auto_attach').respond(task);
        Organization.autoAttach(function(results) {
            expect(results.id).toBe(task.id);
        });
    });
});
