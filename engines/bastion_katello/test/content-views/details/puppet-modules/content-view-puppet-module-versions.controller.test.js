describe('Controller: ContentViewPuppetModuleVersionsController', function() {
    var $scope, $controller, dependencies, ContentView, ContentViewPuppetModule, puppetModule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'))

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');
        ContentView = $injector.get('MockResource').$new();
        ContentViewPuppetModule = $injector.get('MockResource').$new();
        ContentView.availablePuppetModules = function () {};

        puppetModule = {
            uuid: 'abcd',
            name: "puppet",
            author: 'Geppetto'
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};

        $scope.$stateParams.contentViewId = 1;
        $scope.$stateParams.moduleName = 'puppet';

        dependencies = {
            $scope: $scope,
            ContentView: ContentView,
            ContentViewPuppetModule: ContentViewPuppetModule
        };

        $controller('ContentViewPuppetModuleVersionsController', dependencies);
    }));

    it("sets a versions loading indicator on the $scope", function() {
        expect($scope.versionsLoading).toBe(true);
    });

    it("sets the puppet module versions on the $scope", function () {
        ContentView.availablePuppetModules = function (data, callback) {
            callback();
        };

        spyOn(ContentView, 'availablePuppetModules').and.callThrough();

        $controller('ContentViewPuppetModuleVersionsController', dependencies);

        expect(ContentView.availablePuppetModules).toHaveBeenCalledWith({id: 1, name: 'puppet'}, jasmine.any(Function));
        expect($scope.versionsLoading).toBe(false);
    });

    it("provides a way to create a new content view puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.puppet-modules.list',
            {contentViewId: 1});
        expect($scope.successMessages.length).toBe(1);
    });

    it("provides a way to updating an existing content view puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.$stateParams.moduleId = 3;
        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.puppet-modules.list',
            {contentViewId: 1});
        expect($scope.successMessages.length).toBe(1);
    });

    it("provides a way to select the latest version of a puppet module", function () {
        spyOn($scope, 'transitionTo');
        puppetModule.useLatest = true;

        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.puppet-modules.list',
            {contentViewId: 1});
        expect($scope.successMessages.length).toBe(1);
    });
});
