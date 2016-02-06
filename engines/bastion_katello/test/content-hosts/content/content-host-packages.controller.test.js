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

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();
        $scope.host = mockHost;
        $scope.$stateParams = {hostId: mockHost.id};

        $controller('ContentHostPackagesController', {$scope: $scope,
                                               HostPackage: HostPackage,
                                               translate:translate,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.detailsTable).toBeTruthy();
    });

    it("provides a way to open the event details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.detailsTable.openEventInfo({ id: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.details.events.details', {eventId: 2});
    });

    it("defaults to package install", function() {
        expect($scope.packageAction.actionType).toBe('packageInstall');
    });

    it("properly recognizes a failed package remove task", function() {
        expect($scope.detailsTable.taskFailed({failed: true})).toBe(true);
        expect($scope.detailsTable.taskFailed({failed: false})).toBe(false);
        expect($scope.detailsTable.taskFailed({failed: false, affected_units: 0})).toBe(true);
        expect($scope.detailsTable.taskFailed({failed: false, affected_units: 1})).toBe(false);
    });

    it("performs a package update", function() {
        spyOn(HostPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo";
        $scope.performPackageAction();
        expect(HostPackage.update).toHaveBeenCalledWith({id: mockHost.id, packages: ["foo"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package update with multiple packages", function() {
        spyOn(HostPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo, bar";
        $scope.performPackageAction();
        expect(HostPackage.update).toHaveBeenCalledWith({id: mockHost.id, packages: ["foo", "bar"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package group install", function() {
        spyOn(HostPackage, 'install');
        $scope.packageAction.actionType = "groupInstall";
        $scope.packageAction.term = "bigGroup";
        $scope.performPackageAction();
        expect(HostPackage.install).toHaveBeenCalledWith({id: mockHost.id, groups: ["bigGroup"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a selected package removal", function() {
        var mockPackage, mockPackageClone;
        mockPackage = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        mockPackageClone = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        spyOn($scope.detailsTable,  'getSelected').andReturn([mockPackage]);

        spyOn(HostPackage, 'remove');
        $scope.removeSelectedPackages();
        expect(HostPackage.remove).toHaveBeenCalledWith({id: mockHost.id, packages: [mockPackageClone]},
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
