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
        org,
        Organization,
        task;

    beforeEach(module('Bastion.organizations'));

    beforeEach(module(function($provide) {
        org = {
            label: 'acme',
            name: 'Acme',
            id: 1
        };
        task = {
            id: 7
        }
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Organization = $injector.get('Organization');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get repo discover', function(){
        $httpBackend.expectPOST('/katello/api/organizations/ACME/repo_discover').respond(task);

        Organization.repoDiscover({ id: 'ACME' , url: '/foo'});
    });

    it('provides a way to cancel repo discover', function(){
        $httpBackend.expectPOST('/katello/api/organizations/ACME/repo_discover').respond(task);

        Organization.repoDiscover({ id: 'ACME' , url: '/foo'});
    });

    it('provides a way to get an org', function() {
        $httpBackend.expectGET('/katello/api/organizations/ACME').respond(org);

        Organization.query({ id: 'ACME' }, function(response) {
            expect(response.id).toBe(org.id);
        });
    });

});
