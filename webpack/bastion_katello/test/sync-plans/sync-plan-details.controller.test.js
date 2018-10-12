describe('Controller: SyncPlanDetailsController', function() {
    var $scope, Notification;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state'),
            SyncPlan = $injector.get('MockResource').$new();

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {syncPlanId: 1};

        $controller('SyncPlanDetailsController', {
            $scope: $scope,
            $state: $state,
            Notification: Notification,
            SyncPlan: SyncPlan
        });
    }));

    it("gets the sync plan using the SyncPlan service and puts it on the $scope.", function() {
        expect($scope.syncPlan).toBeDefined();
    });

    it('provides a way to remove a sync plan', function() {
        var syncPlanInstance = {
            id: 1,
            $remove: function (callback) {
                callback();
            }
        };
        spyOn($scope, 'transitionTo');
        spyOn(syncPlanInstance, '$remove').and.callThrough();

        $scope.removeSyncPlan(syncPlanInstance);

        expect(syncPlanInstance.$remove).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('sync-plans');
    });
});
