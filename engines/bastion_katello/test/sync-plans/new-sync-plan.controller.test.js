describe('Controller: NewSyncPlanController', function() {
    var $scope, translate, SyncPlan, GlobalNotification;

    beforeEach(module(
        'Bastion.sync-plans',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        SyncPlan = $injector.get('MockResource').$new()
        GlobalNotification = $injector.get('GlobalNotification');
        $scope = $injector.get('$rootScope').$new();
        $scope.$state = {go: function () {}};
        $scope.nutupane = {refresh: function () {}};

        translate = function (string) { return string; };

        $scope.syncPlanTable = {
            rows: {
                unshift: function () {}
             }
         };

        $controller('NewSyncPlanController', {
            $scope: $scope,
            translate: translate,
            SyncPlan: SyncPlan,
            GlobalNotification: GlobalNotification
        });
    }));

    it('should attach a sync plan resource on to the scope', function() {
        expect($scope.syncPlan).toBeDefined();
    });

    describe('sync date', function() {
        it('should save a sync date in MM/DD/YYYY HH:MM:SS format', function() {
            var syncPlan = {};
            syncPlan.startDate = new Date('08/05/2015 00:00:00');
            syncPlan.startTime = new Date('09/09/1999 13:00:00');

            syncPlan.$save = function() {};
            spyOn(syncPlan, '$save').and.callThrough();
            
            $scope.createSyncPlan(syncPlan);

            var syncDate = new Date(syncPlan['sync_date']);

            expect(syncDate.getHours()).toBe(13);
            expect(syncDate.getMinutes()).toBe(0);
            expect(syncDate.getDate()).toBe(5);
            expect(syncDate.getMonth()).toBe(7);
            expect(syncDate.getFullYear()).toBe(2015);
            expect(syncPlan.$save).toHaveBeenCalled();
        });

        it('should save a sync date in YYYY-MM-DD HH:MM:SS format', function() {
            var syncPlan = {};
            syncPlan.startDate = new Date('2015-08-05T00:00:00');
            syncPlan.startTime = new Date('09/09/1999 13:00:00');

            syncPlan.$save = function() {};
            spyOn(syncPlan, '$save').and.callThrough();

            $scope.createSyncPlan(syncPlan);

            var syncDate = new Date(syncPlan['sync_date']);

            expect(syncDate.getHours()).toBe(13);
            expect(syncDate.getMinutes()).toBe(0);
            expect(syncDate.getDate()).toBe(5);
            expect(syncDate.getMonth()).toBe(7);
            expect(syncDate.getFullYear()).toBe(2015);
            expect(syncPlan.$save).toHaveBeenCalled();
        });
    });

    it('should save a new sync plan resource and transform to the newly created sync plan', function() {
        var startDate = new Date('11/17/1982'),
            syncPlan = {id: 1, startDate: startDate, endDate: '14:40'};
        syncPlan.$save = new SyncPlan().$save;

        spyOn($scope.$state, 'go');
        spyOn(syncPlan, '$save').and.callThrough();
        spyOn($scope.syncPlanTable.rows, 'unshift');
        spyOn(GlobalNotification, "setSuccessMessage");

        $scope.createSyncPlan(syncPlan);

        expect($scope.working).toBe(false);
        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.syncPlanTable.rows.unshift).toHaveBeenCalledWith(syncPlan);
        expect($scope.$state.go).toHaveBeenCalledWith('sync-plans.details.info', {syncPlanId: syncPlan.id});
    });

    it('should save a new sync plan resource and transform to the product if called from there', function() {
        var startDate = new Date('11/17/1982'),
            syncPlan = {id: 1, startDate: startDate, endDate: '14:40'};
        syncPlan.$save = new SyncPlan().$save;

        spyOn($scope.$state, 'go');
        spyOn(syncPlan, '$save').and.callThrough();
        spyOn(GlobalNotification, "setSuccessMessage");

        $scope.product = {id: 1};
        $scope.createSyncPlan(syncPlan);

        expect($scope.working).toBe(false);
        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.$state.go).toHaveBeenCalledWith('product.info', {productId: $scope.product.id});
    });
});
