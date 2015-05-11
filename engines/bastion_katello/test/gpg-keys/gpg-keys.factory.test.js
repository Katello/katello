describe('Factory: GPGKey', function() {
    var $httpBackend,
        gpgKeys;

    beforeEach(module('Bastion.gpg-keys', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        gpgKeys = {
            records: [
                { name: 'GPGKey1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        GPGKey = $injector.get('GPGKey');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositorys', function() {
        $httpBackend.expectGET('/katello/api/v2/gpg_keys?organization_id=ACME').respond(gpgKeys);

        GPGKey.queryPaged(function(gpgKeys) {
            expect(gpgKeys.records.length).toBe(1);
        });
    });

});
