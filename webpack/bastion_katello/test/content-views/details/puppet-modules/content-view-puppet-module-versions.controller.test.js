describe('Controller: ContentViewPuppetModuleVersionsController', function() {
    var $scope, $controller, dependencies, ContentView, ContentViewPuppetModule, puppetModule, Notification;

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

        Notification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};

        $scope.$stateParams.contentViewId = 1;
        $scope.$stateParams.moduleName = 'puppet';

        dependencies = {
            $scope: $scope,
            ContentView: ContentView,
            ContentViewPuppetModule: ContentViewPuppetModule,
            Notification: Notification
        };

        $controller('ContentViewPuppetModuleVersionsController', dependencies);
    }));

    it("sets a nutupane table on the $scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("provides a way to create a new content view puppet module", function () {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, 'setSuccessMessage');

        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.puppet-modules.list',
            {contentViewId: 1});
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it("provides a way to updating an existing content view puppet module", function () {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, 'setSuccessMessage');

        $scope.$stateParams.moduleId = 3;
        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.puppet-modules.list',
            {contentViewId: 1});
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it("provides a way to select the latest version of a puppet module", function () {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, 'setSuccessMessage');

        puppetModule.useLatest = true;

        $scope.selectVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.puppet-modules.list',
            {contentViewId: 1});
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });
});
