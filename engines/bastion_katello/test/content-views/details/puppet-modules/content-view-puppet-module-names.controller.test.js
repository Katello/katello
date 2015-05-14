describe('Controller: ContentViewPuppetModuleNamesController', function() {
    var $scope, $controller, dependencies, ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');
        ContentView = $injector.get('MockResource').$new();
        ContentView.availablePuppetModuleNames = function () {};

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};
        $scope.$stateParams.contentViewId = 1;

        dependencies = {
            $scope: $scope,
            ContentView: ContentView
        };

        $controller('ContentViewPuppetModuleNamesController', dependencies);
    }));

    it("sets a nutupane table on the $scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("provides a way to select a new version of the puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.selectVersion("puppet");

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.puppet-modules.versions',
            {contentViewId: 1, moduleName: "puppet"}
        );
    });
});
