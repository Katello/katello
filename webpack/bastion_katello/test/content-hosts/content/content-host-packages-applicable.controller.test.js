describe('Controller: ContentHostPackagesApplicableController', function() {
    var $scope, Nutupane, Package, mockHost, mockTask, translate, ContentHost;

    beforeEach(module('Bastion.content-hosts', 'Bastion.hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        var mockPackage = {name: 'foo', version: '3', release: '14', arch: 'noarch'};

        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function () {return [mockPackage]}
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

        mockTask = {
            pending: true,
            id: 7
        };
        translate = function() {};

    });

    beforeEach(inject(function($controller, $rootScope, $window, $injector) {
        $scope = $rootScope.$new();
        $scope.host = mockHost;
        $scope.$stateParams = {hostId: mockHost.id};
        $scope.openEventInfo = function(){};
        $scope.errorHandler = function(){};
        $scope.performViaRemoteExecution = function() {};
        $scope.performViaKatelloAgent = function() {};
        Package = $injector.get('MockResource').$new();


        $controller('ContentHostPackagesApplicableController', {$scope: $scope,
                                               Package: Package,
                                               translate:translate,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.table).toBeTruthy();
    });

    it("formats selected items", function() {
        expect($scope.getSelectedPackages()[0]).toBe("foo-3-14.noarch");
    });

    it("performs default action as appropriate for katello agent", function() {
        spyOn($scope, 'performViaKatelloAgent');
        $scope.remoteExecutionByDefault = false;
        $scope.performDefaultUpdateAction();

        expect($scope.performViaKatelloAgent).toHaveBeenCalledWith('packageUpdate', $scope.getKatelloAgentCommand());
    });

    it("performs default action as appropriate for rex", function() {
        spyOn($scope, 'performViaRemoteExecution');
        $scope.remoteExecutionByDefault = true;
        $scope.performDefaultUpdateAction();

        expect($scope.performViaRemoteExecution).toHaveBeenCalledWith('packageUpdate', $scope.getRemoteExecutionCommand(), false);
    });
});
