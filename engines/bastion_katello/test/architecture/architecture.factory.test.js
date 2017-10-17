describe('Factory: Architecture', function() {
    var $httpBackend,
        architecture;

    beforeEach(module('Bastion.architectures', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        architecture = {
            records: [
                { name: 'Architecture1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Architecture = $injector.get('Architecture');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of architectures', function() {
         $httpBackend.expectGET('api/v2/architectures?full_result=true').respond(architecture);

         Architecture.queryUnpaged(function(architecture) {
             expect(architecture.records.length).toBe(1);
         });
    });
});