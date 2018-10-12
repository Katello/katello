describe('Factory: Capsule', function() {
    var $httpBackend,
        capsules,
        Capsule;

    beforeEach(module('Bastion.capsules', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        capsules = {
            records: [
                { name: 'Capsule1', id: 1 },
                { name: 'Capsule2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Capsule = $injector.get('Capsule');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of products', function() {
        $httpBackend.expectGET('katello/api/capsules?full_result=true').respond(capsules);

        Capsule.queryUnpaged(function(capsules) {
            expect(capsules.records.length).toBe(2);
        });
    });

});

