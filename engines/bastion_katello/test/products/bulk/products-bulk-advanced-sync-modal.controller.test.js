describe('Controller: ProductsBulkAdvancedSyncModalController', function() {
    var $scope, $q, $uibModalInstance, translate, ProductBulkAction, CurrentOrganization, Notification, bulkParams;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        bulkParams = {ids: [1, 2, 3]};
        ProductBulkAction = {
            removeProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
            syncProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
            updateProductSyncPlan: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;
        Notification = _Notification_;

        $scope.table = {
            getSelected: function () { return selected; }
        };

        $controller('ProductsBulkSyncPlanModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            bulkParams: bulkParams,
            translate: translate,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: CurrentOrganization,
            Notification: Notification
        });
    }));

    it("allows the updating of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').and.callThrough();

        $scope.selectedSyncPlan = {id: 10};
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

    it("provides a function for closing the modal", function () {
        spyOn($uibModalInstance, 'close');
        $scope.ok();
        expect($uibModalInstance.close).toHaveBeenCalled();
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });
});
