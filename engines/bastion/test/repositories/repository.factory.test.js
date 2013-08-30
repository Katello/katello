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
    });

    it('provides a way to get a list of repositorys', function() {
        $httpBackend.expectGET('/katello/api/products/1/repositories').respond(repositories);

        Repository.query({ productId: 1 }, function(repositories) {
            expect(repositories.records.length).toBe(1);
        });
    });

    it('provides a way to update a repository', function() {
        var updatedRepository = repositories.records[0];

        updatedRepository.name = 'NewRepositoryName';
        $httpBackend.expectPUT('/katello/api/products/repositories/1').respond(updatedRepository);

        Repository.update({ productId: 1, id: 1 }, function(repository) {
            expect(repository).toBeDefined();
            expect(repository.name).toBe('NewRepositoryName');
        });
    });

});

