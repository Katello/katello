describe('Factory: Repository', function() {
    var $httpBackend,
        repositories;

    beforeEach(module('Bastion.repositories', 'Bastion.test-mocks'));

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
        $httpBackend.expectGET('katello/api/v2/repositories?organization_id=ACME&product_id=1')
                    .respond(repositories);

        Repository.queryPaged({'product_id': 1}, function(repositories) {
            expect(repositories.records.length).toBe(1);
        });
    });

    it('provides a way to update a repository', function() {
        var updatedRepository = repositories.records[0];

        updatedRepository.name = 'NewRepositoryName';
        $httpBackend.expectPUT('katello/api/v2/repositories/1?organization_id=ACME').respond(updatedRepository);

        Repository.update({name: 'NewRepositoryName', id: 1}, function(repository) {
            expect(repository).toBeDefined();
            expect(repository.name).toBe('NewRepositoryName');
        });
    });

    it('provides a way to sync a repository', function() {
        $httpBackend.expectPOST('katello/api/v2/repositories/1/sync?organization_id=ACME').respond({'state': 'running'});

        Repository.sync({id: 1}, function(task) {
            expect(task).toBeDefined();
            expect(task['state']).toBe('running');
        });
    });

});

