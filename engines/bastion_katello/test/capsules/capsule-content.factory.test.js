describe('Factory: CapsuleContent', function () {
    var $httpBackend, CapsuleContent;

    beforeEach(module('Bastion.capsule-content', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        CapsuleContent = $injector.get('CapsuleContent');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get synchronization status', function () {
        $httpBackend.expectGET('katello/api/capsules/1/content/sync').respond({});
        CapsuleContent.syncStatus({ id: 1 });
    });

    it('provides a way to start synchronization', function () {
        $httpBackend.expectPOST('katello/api/capsules/1/content/sync').respond({});
        CapsuleContent.sync({ id: 1 });
    });

    it('provides a way to cancel synchronization', function () {
        $httpBackend.expectDELETE('katello/api/capsules/1/content/sync').respond({});
        CapsuleContent.cancelSync({ id: 1 });
    });
});
