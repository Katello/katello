describe('Factory: Setting', function () {
    var $httpBackend,
        setting;

    beforeEach(module('Bastion.settings', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        setting = {
            results: [
                { value: 'true' }
            ]
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Setting = $injector.get('Setting');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of settings', function () {
        $httpBackend.expectGET('api/v2/settings').respond(setting);

        Setting.queryPaged(function (setting) {
            expect(setting.results.length).toBeGreaterThan(0);
        });
    });
});

