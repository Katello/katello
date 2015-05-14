describe('Factory: CustomInfo', function() {
    var $httpBackend;

    beforeEach(module('Bastion.custom-info', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        CustomInfo = $injector.get('CustomInfo');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to update custom info', function() {
        $httpBackend.expectPUT('/katello/api/v2/custom_info/system/1/newKey')
                    .respond({});

        CustomInfo.update({
            id: 1,
            type: 'system',
            action: 'newKey',
        }, {
            'newKey': 'keyValue',
        }, function(customInfo) {
            expect(customInfo).toBeDefined();
        });
    });

    it('provides a way to create custom info', function() {
        $httpBackend.expectPOST('/katello/api/v2/custom_info/system/1')
                    .respond({});

        CustomInfo.save({
            id: 1,
            type: 'system'
        }, {
            'newKey': 'keyValue',
        }, function(customInfo) {
            expect(customInfo).toBeDefined();
        });
    });

    it('provides a way to delete custom info', function() {
        $httpBackend.expectDELETE('/katello/api/v2/custom_info/system/1/newKey')
                    .respond();

        CustomInfo.delete({
            id: 1,
            type: 'system',
            action: 'newKey'
        });
    });

});

