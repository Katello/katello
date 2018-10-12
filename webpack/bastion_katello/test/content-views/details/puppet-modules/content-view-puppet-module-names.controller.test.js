describe('Controller: ContentViewPuppetModuleNamesController', function() {
    var $scope, $controller, dependencies, ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');
        ContentView = $injector.get('MockResource').$new();
        PuppetModule = $injector.get('MockResource').$new();
        PuppetModule.autocomplete = function(){return {$promise: {then: function(callback) {callback([])}}}};

        ContentView.availablePuppetModuleNames = function () {};

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};
        $scope.$stateParams.contentViewId = 1;

        dependencies = {
            $scope: $scope,
            ContentView: ContentView,
            PuppetModule: PuppetModule,
            CurrentOrganization: 1
        };

        $controller('ContentViewPuppetModuleNamesController', dependencies);
    }));

    it("sets a nutupane table on the $scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("provides a way to select a new version of the puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.selectVersion("puppet");

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.puppet-modules.versions',
            {contentViewId: 1, moduleName: "puppet"}
        );
    });

    it("Auto completes to puppet modules", function() {
        spyOn(PuppetModule, 'autocomplete').and.callThrough();

        $scope.table.fetchAutocomplete('foobar');
        expect(PuppetModule.autocomplete).toHaveBeenCalledWith({'organization_id': 1, search: 'foobar'})
    });
});
