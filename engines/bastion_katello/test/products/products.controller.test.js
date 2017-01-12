describe('Controller: ProductsController', function() {
    var $scope,
        $uibModal,
        GlobalNotification,
        ProductBulkAction,
        Nutupane;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function () {
                    return [{id: 1}, {id: 2}, {id: 3}];
                }
            };
            this.get = function() {};
            this.invalidate = function () {};
        };
        ProductBulkAction = {
            removeProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
            syncProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };

        Product = {};
        $uibModal = {
            open: function () {
                return {
                    closed: {
                        then: function() {}
                    }
                }
            }
        };
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        GlobalNotification = _GlobalNotification_;

        $controller('ProductsController', {
            $scope: $scope,
            $location: $location,
            $uibModal: $uibModal,
            Nutupane: Nutupane,
            Product: Product,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: 'foo',
            GlobalNotification: GlobalNotification
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
    
    it('properly detects most important sync state error', function () {
        var product = {
            'sync_summary': {
                'error': 1,
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('error');
    });

    it('properly detects most important sync state pending', function () {
        var product = {
            'sync_summary': {
                'pending': 1,
                'error': 1,
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('pending');
    });

    it('properly detects most important sync state success', function () {
        var product = {
            'sync_summary': {
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('success');
    });

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

    it("can open a sync plan modal", function () {
        var result;
        spyOn($uibModal, 'open').and.callThrough();

        $scope.openSyncPlanModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('products-bulk-sync-plan-modal.html');
        expect(result.controller).toBe('ProductsBulkSyncPlanModalController');
    });
});

