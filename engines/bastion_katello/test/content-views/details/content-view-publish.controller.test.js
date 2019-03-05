describe('Controller: ContentViewPublishController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        ContentView.publish = function(options, callback) {  callback({id: 3}) };
        $scope = $injector.get('$rootScope').$new();
        $scope.reloadVersions = function () {};

        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView.versions = [];
        $scope.$stateParams = {contentViewId: 1};
        $scope.fetchContentView = function() {};

        spyOn($scope, 'transitionTo');
        spyOn($scope, 'reloadVersions');

        $controller('ContentViewPublishController', {
            $scope: $scope,
            translate: translate,
            ContentView: ContentView,
            contentViewSolveDependencies: false
        });
    }));

    it("puts an empty version on the scope", function() {
        expect($scope.version).toBeDefined();
    });

    it('provides a method to publish a content view version', function() {
        $scope.publish($scope.contentView, $scope.version);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.versions',
            {contentViewId: $scope.contentView.id});
    });

    // dependency solving testing
    // order within array is: content view setting, global setting, skip solve deps checkbox, result
    var scenarios = [
      [false, false, false, false],
      [false, true, false, true],
      [true, false, false, true],
      [true, true, false, true],
      [true, false, true, false],
      [false, true, true, false],
      [true, true, true, false]
    ];

    scenarios.map(function(scenario) {
      it('calculates solve dependencies correctly, scenario: ' + scenario.join(', '), function() {
        var contentViewSetting = scenario[0],
            globalSetting = scenario[1],
            skipSolveDep = scenario[2]
        expect($scope.calculateSolveDeps(contentViewSetting, globalSetting, skipSolveDep)).toBe(scenario[3]);
      });
    });
});
