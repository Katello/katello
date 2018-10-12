describe('Factory: DockerManifestList', function () {
    var $httpBackend,
        dockerManifestLists;

    beforeEach(module('Bastion.docker-manifest-lists', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        dockerManifestLists = {
            records: [
                { digest: 'abc123', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        DockerManifestList = $injector.get('DockerManifestList');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('katello/api/v2/docker_manifest_lists').respond(dockerManifestLists);

        DockerManifestList.queryPaged(function (dockerManifestLists) {
            expect(dockerManifestLists.records.length).toBe(1);
        });
    });

});
