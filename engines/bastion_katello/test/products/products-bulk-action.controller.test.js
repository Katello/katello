describe('Controller: ProductsBulkActionController', function() {
    var $scope, $q, translate, ProductBulkAction, CurrentOrganization, GlobalNotification, selected;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        selected = [{id: 1}, {id: 2}, {id: 3}];
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
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;
        GlobalNotification = _GlobalNotification_;

        $scope.table = {
            getSelected: function () { return selected; }
        };

        $controller('ProductsBulkActionController', {
            $scope: $scope,
            translate: translate,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: CurrentOrganization,
            GlobalNotification: GlobalNotification
        });
    }));

    it("can remove multiple products", function() {
        spyOn(ProductBulkAction, 'removeProducts').and.callThrough();

        $scope.removeProducts();

        expect(ProductBulkAction.removeProducts).toHaveBeenCalledWith(_.extend({ids: [1, 2, 3]}, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can sync products", function() {
        spyOn(ProductBulkAction, 'syncProducts').and.callThrough();
        $scope.syncProducts();

        expect(ProductBulkAction.syncProducts).toHaveBeenCalledWith({ids: [1, 2, 3], 'organization_id': 'foo'},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("allows the updating of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').and.callThrough();

        $scope.updateSyncPlan({id: 10});

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'organization_id': 'foo', 'plan_id': 10},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("allows the removal of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').and.callThrough();

        $scope.removeSyncPlan();

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'organization_id': 'foo', 'plan_id': null},
            jasmine.any(Function), jasmine.any(Function));
    });
});
