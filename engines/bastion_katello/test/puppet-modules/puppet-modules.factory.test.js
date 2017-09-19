describe('Factory: PuppetModules', function () {
    var $httpBackend,
        puppetModules;

    beforeEach(module('Bastion.puppet-modules', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        puppetModules = {
            records: [
                { name: 'PuppetModules1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        PuppetModule = $injector.get('PuppetModule');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of puppet modules', function () {
        $httpBackend.expectGET('katello/api/v2/puppet_modules').respond(puppetModules);

        PuppetModule.queryPaged(function (puppetModules) {
            expect(puppetModules.records.length).toBe(1);
        });
    });

    it('provides a way to get autocompleted search terms for puppet modules', function () {
        $httpBackend.expectGET('katello/api/v2/puppet_modules/auto_complete_search').respond(puppetModules.records);

        PuppetModule.autocomplete(function (puppetModules) {
            expect(puppetModules.length).toBe(1);
        });
    });

});
