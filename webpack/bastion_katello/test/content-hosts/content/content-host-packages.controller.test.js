describe('Controller: ContentHostPackagesController', function() {
    var $scope, Nutupane, HostPackage, mockHost, mockTask, translate, ContentHost;

    beforeEach(module('Bastion.content-hosts', 'Bastion.hosts', 'Bastion.test-mocks'));

    beforeEach(function() {

        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function () {}
            };
            this.get = function() {};
            this.load = function() {};
            this.setParams = function () {};
        };
        ContentHost = {
            tasks: function() {return []}
        };
        mockHost = {
          id: 23434
        };
        HostPackage = {
            get: function() {return []},
            remove: function(params, success) {
                success(mockTask);
                return mockTask
            },
            install: function() {return mockTask},
            update: function() {return mockTask},
            updateAll: function() {return mockTask}
        };

        mockTask = {
            pending: true,
            id: 7
        };
        translate = function() {};

    });

    beforeEach(inject(function($controller, $rootScope, $window, MockResource) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope = $rootScope.$new();
        $scope.host = mockHost;
        $scope.$stateParams = {hostId: mockHost.id};

        $controller('ContentHostPackagesController', {$scope: $scope,
                                               HostPackage: HostPackage,
                                               translate:translate,
                                               Nutupane: Nutupane});
    }));

    it("provides a way to open the event details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.openEventInfo({ id: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('content-host.events.details', {eventId: 2});
    });

    it("performs a package update", function() {
        spyOn(HostPackage, 'update');
        $scope.performPackageAction('packageUpdate', 'foo');
        expect(HostPackage.update).toHaveBeenCalledWith({id: mockHost.id, packages: ["foo"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package update with multiple packages", function() {
        spyOn(HostPackage, 'update');
        $scope.performPackageAction('packageUpdate', 'foo, bar');
        expect(HostPackage.update).toHaveBeenCalledWith({id: mockHost.id, packages: ["foo", "bar"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package group install", function() {
        spyOn(HostPackage, 'install');
        $scope.performPackageAction('groupInstall', 'bigGroup');
        expect(HostPackage.install).toHaveBeenCalledWith({id: mockHost.id, groups: ["bigGroup"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("provides a way to upgrade all packages", function() {
        spyOn(HostPackage, "updateAll");
        $scope.updateAll();
        expect(HostPackage.updateAll).toHaveBeenCalledWith({id: mockHost.id}, jasmine.any(Function),
            jasmine.any(Function));
        expect($scope.working).toBe(true);
    });
});
