describe('Controller: SyncPlanDetailsController', function() {
    var $scope;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state'),
            SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {syncPlanId: 1};

        $controller('SyncPlanDetailsController', {
            $scope: $scope,
            $state: $state,
            SyncPlan: SyncPlan
        });
    }));

    it("gets the sync plan using the SyncPlan service and puts it on the $scope.", function() {
        expect($scope.syncPlan).toBeDefined();
    });

});
