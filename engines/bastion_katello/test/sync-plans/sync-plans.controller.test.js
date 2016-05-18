describe('Controller: SyncPlansController', function() {
    var $scope,
        translate,
        Nutupane,
        SyncPlan;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function () {};
            this.removeRow = function () {};
            this.refresh = function () {};
        };

        translate = function (string) {
            return string;
        };

        SyncPlan = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('SyncPlansController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Nutupane: Nutupane,
            SyncPlan: SyncPlan,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.syncPlanTable).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.syncPlanTable.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('sync-plans.index');
    });

    it('provides a way to remove a sync plan', function() {
        var syncPlanInstance = {
            id: 1,
            $remove: function (callback) {
                callback();
            }
        };
        spyOn($scope, 'removeRow');
        spyOn($scope, 'transitionTo');
        spyOn(syncPlanInstance, '$remove').andCallThrough();

        $scope.removeSyncPlan(syncPlanInstance);

        expect(syncPlanInstance.$remove).toHaveBeenCalled();
        expect($scope.removeRow).toHaveBeenCalledWith(1);
        expect($scope.transitionTo).toHaveBeenCalledWith('sync-plans.index');
    });

});

