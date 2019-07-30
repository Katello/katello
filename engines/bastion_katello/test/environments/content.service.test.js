describe('Service: ContentService', function() {
    var ContentService, Package, ModuleStream, $state;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        $state = $injector.get('$state');
        ContentService = $injector.get('ContentService');
    }));

    it("should expose the list of content types", function() {
        expect(ContentService.contentTypes.length).toBe(8);
    });

    it("should provide a method to build a nutupane based on params", function () {
        $state.current = {name: 'environment.packages'};
        var nutupane = ContentService.buildNutupane({environmentId: 1});

        expect(nutupane.getParams()['environmentId']).toBe(1);
        expect(nutupane.disableAutoLoad).toBe(true);
    });

    describe ('Package', function() {
        beforeEach(inject(function ($injector) {
            $state.current = {name: 'environment.packages'};
            Package = $injector.get('Package');
        }));

        it("should expose a method to get the repository type for an object", function() {
            expect(ContentService.getRepositoryType()).toBe('yum');
        });

        it("should provide a method to build a nutupane based on the current state", function () {
            var nutupane = ContentService.buildNutupane();

            expect(nutupane.table.resource).toBe(Package);
            expect(nutupane.disableAutoLoad).toBe(true);
        });
    });

    describe ('ModuleStream', function() {
        beforeEach(inject(function ($injector) {
            $state.current = {name: 'environment.module-streams'};
            ModuleStream = $injector.get('ModuleStream');
        }));

        it("should expose a method to get the repository type for an object", function() {
            expect(ContentService.getRepositoryType()).toBe('yum');
        });

        it("should provide a method to build a nutupane based on the current state", function () {
            var nutupane = ContentService.buildNutupane();

            expect(nutupane.table.resource).toBe(ModuleStream);
            expect(nutupane.disableAutoLoad).toBe(true);
        });
    });

    describe('Content Views', function() {
        beforeEach(inject(function ($injector) {
            $state.current = {name: 'environment.content-views'};
            ContentView = $injector.get('ContentView');
        }));

        it("auto loads nutupane", function () {
            var nutupane = ContentService.buildNutupane();

            expect(nutupane.disableAutoLoad).toBe(false);
            expect(nutupane.table.resource).toBe(ContentView);
        });
    });
});

