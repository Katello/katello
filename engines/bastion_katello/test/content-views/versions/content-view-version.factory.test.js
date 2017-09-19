describe('Factory: ContentViewVersion', function () {
    var $httpBackend,
        contentViewVersion;

    beforeEach(module('Bastion.content-views.versions', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        contentViewVersion = {
            records: [
                { name: 'ContentViewVersion1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentViewVersion = $injector.get('ContentViewVersion');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('katello/api/v2/content_view_versions').respond(contentViewVersion);

        ContentViewVersion.queryPaged(function (contentViewVersion) {
            expect(contentViewVersion.records.length).toBe(1);
        });
    });

    it('provides a way to get an incremental update', function () {
        $httpBackend.expectPOST('katello/api/v2/content_view_versions/incremental_update').respond({});
        ContentViewVersion.incrementalUpdate();
    });
});
