describe('Factory: ModuleStream', function () {
    var $httpBackend,
        moduleStreams;

    beforeEach(module('Bastion.module-streams', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        moduleStreams = {
            records: [
                { name: 'abc123', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ModuleStream = $injector.get('ModuleStream');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('katello/api/v2/module_streams').respond(moduleStreams);

        ModuleStream.queryPaged(function (moduleStreams) {
            expect(moduleStreams.records.length).toBe(1);
        });
    });

});
