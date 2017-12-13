describe('Factory: ContentCredential', function() {
    var $httpBackend,
        contentCredentials;

    beforeEach(module('Bastion.content-credentials', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        contentCredentials = {
            records: [
                { name: 'ContentCredential1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentCredential = $injector.get('ContentCredential');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositorys', function() {
        $httpBackend.expectGET('katello/api/v2/content_credentials?organization_id=ACME').respond(contentCredentials);

        ContentCredential.queryPaged(function(contentCredentials) {
            expect(contentCredentials.records.length).toBe(1);
        });
    });

});
