describe('Service: ContentService', function() {
    var ContentService, Package;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        var $state = $injector.get('$state');

        $state.current = {name: 'environments.environment.packages'};
        Package = $injector.get('Package');
        ContentService = $injector.get('ContentService');
    }));

    it("should expose the list of content types", function() {
        expect(ContentService.contentTypes.length).toBe(6);
    });

    it("should expose a method to get the repository type for an object", function() {
        expect(ContentService.getRepositoryType()).toBe('yum');
    });

    it("should provide a method to build a nutupane based on the current state", function () {
        var nutupane = ContentService.buildNutupane();

        expect(nutupane).toBeDefined();
        expect(nutupane.table.resource).toBe(Package);
    });

    it("should provide a method to build a nutupane based on params", function () {
        var nutupane = ContentService.buildNutupane({environmentId: 1});

        expect(nutupane).toBeDefined();
        expect(nutupane.getParams()['environmentId']).toBe(1);
    });

});

