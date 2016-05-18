describe('Controller: ProductsBulkActionSyncPlanController', function() {
    var $scope, $q, ProductBulkAction, SyncPlan, Nutupane, selected, GlobalNotification;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        selected = [1, 2, 3];
        ProductBulkAction = {
            updateProductSyncPlan: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };

        Nutupane = function () {
            this.table = {};
        };
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, _$q_, MockResource) {
        $scope = $rootScope.$new();
        $q = _$q_;

        $scope.actionParams = {};
        $scope.getSelectedProductIds = function () { return selected; };
        SyncPlan = MockResource.$new();
        GlobalNotification = _GlobalNotification_;

        $controller('ProductsBulkActionSyncPlanController', {
            $scope: $scope,
            Nutpane: Nutupane,
            SyncPlan: SyncPlan,
            ProductBulkAction: ProductBulkAction,
            GlobalNotification: GlobalNotification
        });
    }));

    it("creates a nutupane sync plan table", function() {
        expect($scope.syncPlanTable).toBeDefined();
    });

    it("allows the updating of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').and.callThrough();

        $scope.syncPlanTable = {chosenRow: {id: 10}};
        $scope.updateSyncPlan();

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'plan_id': 10},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("allows the removal of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').and.callThrough();

        $scope.removeSyncPlan();

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'plan_id': null},
            jasmine.any(Function), jasmine.any(Function));
    });

});
