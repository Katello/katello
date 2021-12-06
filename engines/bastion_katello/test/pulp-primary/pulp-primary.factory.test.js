describe('Factory: PulpPrimary', function () {
    var $httpBackend, PulpPrimary;

    beforeEach(module('Bastion.pulp-primary', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        PulpPrimary = $injector.get('PulpPrimary');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to start space reclamation', function () {
        $httpBackend.expectPOST('katello/api/capsules/1/content/reclaim_space').respond({});
        PulpPrimary.reclaimSpace({ id: 1 });
    });
});
