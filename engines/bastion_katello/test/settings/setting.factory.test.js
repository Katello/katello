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
        OstreeBranch = $injector.get('Setting');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('/api/v2/settings').respond(setting);

        OstreeBranch.queryPaged(function (setting) {
            expect(setting.results.length).toBeGreaterThan(0);
        });
    });
});

