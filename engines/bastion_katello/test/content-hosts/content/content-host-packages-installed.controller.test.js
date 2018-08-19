describe('Controller: ContentHostPackagesInstalledController', function() {
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
        $scope.openEventInfo = function(){};
        $scope.errorHandler = function(){};

        $controller('ContentHostPackagesInstalledController', {$scope: $scope,
                                               HostPackage: HostPackage,
                                               translate:translate,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.table).toBeTruthy();
    });


    it("performs a selected package removal", function() {
        var mockPackage, mockPackageClone;
        mockPackage = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        mockPackageClone = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        spyOn($scope.table,  'getSelected').and.returnValue([mockPackage]);

        spyOn(HostPackage, 'remove');
        $scope.removeSelectedPackages();
        expect(HostPackage.remove).toHaveBeenCalledWith({id: mockHost.id, packages: ['foo']},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });
});
