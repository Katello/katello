describe('Controller: ContentViewPuppetModulesController', function() {
    var $scope, Nutupane, ContentViewPuppetModule, puppetModule, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        Nutupane = function () {
            this.removeRow = function () {};
            this.table = {};
        };

        Notification = {
            setErrorMessage: function () {},
            setSuccessMessage: function () {}
        };

        ContentViewPuppetModule = $injector.get('MockResource').$new();
        puppetModule = {
            id: 3,
            name: "puppet",
            computed_version: '0.2.0'
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};
        $scope.$stateParams.contentViewId = 1;

        $controller('ContentViewPuppetModulesController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentViewPuppetModule: ContentViewPuppetModule,
            Notification: Notification
        });
    }));

    it("puts a content view version table on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    describe("can determine the version text based on the puppet module", function () {
        it("by setting the version to latest", function () {
            expect($scope.versionText(puppetModule)).toBe("Latest (Currently 0.2.0)");
        });

        it("by setting a specific version", function () {
            puppetModule.puppet_module = {version: "0.0.1"};
            expect($scope.versionText(puppetModule)).toBe("0.0.1");
        });
    });

    it("provides a way to select a new version of the puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.selectNewVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.puppet-modules.versionsForModule',
            {contentViewId: 1, moduleName: "puppet", moduleId: 3}
        );
    });

    describe("provides a way to remove a module", function () {
        beforeEach(function () {
            spyOn(ContentViewPuppetModule, 'remove').and.callThrough();
        });

        afterEach(function () {
            expect(ContentViewPuppetModule.remove).toHaveBeenCalledWith({contentViewId: 1, id: 3},
                jasmine.any(Function), jasmine.any(Function));
        });

        it("and succeeds", function () {
            spyOn(Notification, 'setErrorMessage');
            spyOn(Notification, 'setSuccessMessage');

            $scope.removeModule(puppetModule);

            expect(Notification.setSuccessMessage).toHaveBeenCalled();
            expect(Notification.setErrorMessage).not.toHaveBeenCalled();
        });

        it("and fails", function () {
            spyOn(Notification, 'setErrorMessage');
            spyOn(Notification, 'setSuccessMessage');

            ContentViewPuppetModule.failed = true;
            $scope.removeModule(puppetModule);

            expect(Notification.setSuccessMessage).not.toHaveBeenCalled();
            expect(Notification.setErrorMessage).toHaveBeenCalled();
        });
    });
});
