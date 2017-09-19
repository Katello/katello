describe('Factory: Files', function () {
    var $httpBackend,
        files;

    beforeEach(module('Bastion.files', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        files = {
            records: [
                { name: 'Files1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        File = $injector.get('File');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of files', function () {
        $httpBackend.expectGET('katello/api/v2/files').respond(files);

        File.queryPaged(function (files) {
            expect(files.records.length).toBe(1);
        });
    });

    it('provides a way to get autocompleted search terms for files', function () {
        $httpBackend.expectGET('katello/api/v2/files/auto_complete_search').respond(files.records);

        File.autocomplete(function (files) {
            expect(files.length).toBe(1);
        });
    });

});
