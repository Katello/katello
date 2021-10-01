describe('Factory: GenericContent', function () {
    var $httpBackend,
        files;

    beforeEach(module('Bastion.generic-content', 'Bastion.test-mocks'));

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
        GenericContent = $injector.get('GenericContent');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of generic content by type', function () {
        $httpBackend.expectGET('katello/api/v2/python_packages?sort_by=name&sort_order=DESC').respond(files);

        GenericContent.queryPaged({content_type_name: 'python_packages'}, function (files) {
            expect(files.records.length).toBe(1);
        });
    });

    it('provides a way to get autocompleted search terms for files', function () {
        $httpBackend.expectGET('katello/api/v2/python_packages/auto_complete_search?sort_by=name&sort_order=DESC').respond(files.records);

        GenericContent.autocomplete({content_type_name: 'python_packages'}, function (files) {
            expect(files.length).toBe(1);
        });
    });

});
