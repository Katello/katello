describe('Controller: ContentHostPackagesController', function() {
    var $scope, Nutupane, HostPackage, mockHost, mockTask, translate, ContentHost, $timeout;

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
        $timeout = function(data) {};
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
        $scope.remoteExecutionPresent = true;
        $scope.performPackageAction('packageUpdate', 'foo');
        expect($scope.packageActionFormValues.package).toBe('foo');
        expect($scope.packageActionFormValues.remoteAction).toBe('packageUpdate');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [23434] }}));
        expect($scope.packageActionFormValues.customize).toBe(false);
    });

    it("performs a package update with multiple packages", function() {
        $scope.remoteExecutionPresent = true;
        $scope.performPackageAction('packageUpdate', 'foo bar');
        expect($scope.packageActionFormValues.package).toBe('foo bar');
        expect($scope.packageActionFormValues.remoteAction).toBe('packageUpdate');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [23434] }}));
        expect($scope.packageActionFormValues.customize).toBe(false);
    });

    it("performs a package group install", function() {
        $scope.remoteExecutionPresent = true;
        $scope.performPackageAction('groupInstall', 'bigGroup');
        expect($scope.packageActionFormValues.package).toBe('bigGroup');
        expect($scope.packageActionFormValues.remoteAction).toBe('groupInstall');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [23434] }}));
        expect($scope.packageActionFormValues.customize).toBe(false);
    });

    it("provides a way to upgrade all packages via remoteExecution", function() {
        // Removed the test to update all packages because this one now covers it with REX being the only way
        $scope.remoteExecutionPresent = true;
        spyOn(HostPackage, "updateAll");
        $scope.updateAll();
        expect(HostPackage.updateAll).not.toHaveBeenCalled();
        expect($scope.packageActionFormValues.package).toEqual('');
        expect($scope.packageActionFormValues.remoteAction).toEqual('packageUpdate');
        expect($scope.packageActionFormValues.bulkHostIds).toEqual('{"included":{"ids":[' + mockHost.id + ']}}');
        expect($scope.working).toBe(true);
    });

    it("performs a package install via remoteExecution", function() {
        $scope.remoteExecutionPresent = true;
        spyOn(HostPackage, 'install');
        $scope.performPackageAction('packageInstall', 'foo, bar, baz');
        expect(HostPackage.install).not.toHaveBeenCalled();
        expect($scope.packageActionFormValues.package).toEqual('foo bar baz');
        expect($scope.packageActionFormValues.remoteAction).toEqual('packageInstall');
        expect($scope.packageActionFormValues.bulkHostIds).toEqual('{"included":{"ids":[' + mockHost.id + ']}}');
        expect($scope.working).toBe(true);
    });
});
