describe('Factory: DockerManifest', function () {
    var $httpBackend,
        dockerManifests;

    beforeEach(module('Bastion.docker-manifests', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        dockerManifests = {
            records: [
                { name: 'abc123', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        DockerManifest = $injector.get('DockerManifest');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('katello/api/v2/docker_manifests').respond(dockerManifests);

        DockerManifest.queryPaged(function (dockerManifests) {
            expect(dockerManifests.records.length).toBe(1);
        });
    });

});
