describe('Controller: ContentHostDebsController', function() {
    var $scope, Nutupane, HostDeb, mockHost, mockTask, translate, ContentHost;

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
        HostDeb = {
            get: function() {return []},
        };
    });

    beforeEach(inject(function($controller, $rootScope, $window, MockResource) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope = $rootScope.$new();
        $scope.host = mockHost;
        $scope.$stateParams = {hostId: mockHost.id};

        $controller('ContentHostDebsController', {$scope: $scope,
            HostDeb: HostDeb,
            translate:translate,
            Nutupane: Nutupane});
    }));

    it('provides a way to open the event details panel.', function() {
          spyOn($scope, 'transitionTo');
          $scope.openEventInfo({ id: 2 });
          expect($scope.transitionTo).toHaveBeenCalledWith('content-host.events.details', {eventId: 2});
    });

    it("performs a package update", function() {
        // packageActionForm = angular.element('#packageActionForm');
        // spyOn(packageActionForm, 'submit');
        // spyOn(angular, 'element');
        // spyOn('$timeout');
        $scope.performPackageAction('packageUpdate', 'foo');
        expect($scope.packageActionFormValues.package).toBe('foo');
        expect($scope.packageActionFormValues.remoteAction).toBe('packageUpdate');
        expect($scope.packageActionFormValues.hostIds).toBe(23434);
        expect($scope.packageActionFormValues.customize).toBe(false);
        // expect($timeout).toHaveBeenCalledWith(jasmine.any(Function), 0);
        // expect(angular.element).toHaveBeenCalledWith('#packageActionForm');
        // expect(packageActionForm.submit).toHaveBeenCalledWith();
    });

    it("performs a package update with multiple packages", function() {
        $scope.performPackageAction('packageUpdate', 'foo bar');
        expect($scope.packageActionFormValues.package).toBe('foo bar');
        expect($scope.packageActionFormValues.remoteAction).toBe('packageUpdate');
        expect($scope.packageActionFormValues.hostIds).toBe(23434);
        expect($scope.packageActionFormValues.customize).toBe(false);
    });

    it("performs a package group install", function() {
        $scope.performPackageAction('groupInstall', 'bigGroup');
        expect($scope.packageActionFormValues.package).toBe('bigGroup');
        expect($scope.packageActionFormValues.remoteAction).toBe('groupInstall');
        expect($scope.packageActionFormValues.hostIds).toBe(23434);
        expect($scope.packageActionFormValues.customize).toBe(false);
    });

    it("provides a way to upgrade all packages", function() {
        $scope.updateAll();
        expect($scope.working).toBe(true);
        expect($scope.packageActionFormValues.package).toBe('');
        expect($scope.packageActionFormValues.remoteAction).toBe('packageUpdate');
        expect($scope.packageActionFormValues.hostIds).toBe(23434);
        expect($scope.packageActionFormValues.customize).toBe(false);
    });
});
