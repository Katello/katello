describe('Factory: DockerImage', function () {
    var $httpBackend,
        dockerImages;

    beforeEach(module('Bastion.docker-images', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        dockerImages = {
            records: [
                { image_id: 'abc123', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        DockerImage = $injector.get('DockerImage');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('/katello/api/v2/docker_images').respond(dockerImages);

        DockerImage.queryPaged(function (dockerImages) {
            expect(dockerImages.records.length).toBe(1);
        });
    });

});
