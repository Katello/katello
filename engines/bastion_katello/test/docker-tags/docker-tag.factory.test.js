describe('Factory: DockerTag', function () {
    var $httpBackend,
        dockerTags;

    beforeEach(module('Bastion.docker-tags', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        dockerTags = {
            records: [
                { id: 2, name: 'latest' }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        DockerTag = $injector.get('DockerTag');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of tags', function () {
        $httpBackend.expectGET('katello/api/v2/docker_tags').respond(dockerTags);

        DockerTag.queryPaged(function (dockerTags) {
            expect(dockerTags.records.length).toBe(1);
        });
    });

});
