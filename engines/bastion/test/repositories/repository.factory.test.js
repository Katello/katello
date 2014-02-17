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

describe('Factory: Repository', function() {
    var $httpBackend,
        repositories;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function($provide) {
        repositories = {
            records: [
                { name: 'Repository1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Repository = $injector.get('Repository');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function() {
        $httpBackend.expectGET('/api/v2/repositories?organization_id=ACME&product_id=1')
                    .respond(repositories);

        Repository.query({'product_id': 1}, function(repositories) {
            expect(repositories.records.length).toBe(1);
        });
    });

    it('provides a way to update a repository', function() {
        var updatedRepository = repositories.records[0];

        updatedRepository.name = 'NewRepositoryName';
        $httpBackend.expectPUT('/api/v2/repositories/1?organization_id=ACME').respond(updatedRepository);

        Repository.update({name: 'NewRepositoryName', id: 1}, function(repository) {
            expect(repository).toBeDefined();
            expect(repository.name).toBe('NewRepositoryName');
        });
    });

    it('provides a way to sync a repository', function() {
        $httpBackend.expectPOST('/api/v2/repositories/1/sync?organization_id=ACME').respond({'state': 'running'});

        Repository.sync({id: 1}, function(task) {
            expect(task).toBeDefined();
            expect(task['state']).toBe('running');
        });
    });

});

