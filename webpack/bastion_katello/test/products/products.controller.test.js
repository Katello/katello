describe('Controller: ProductsController', function() {
    var $scope,
        $uibModal,
        Notification,
        ProductBulkAction,
        Nutupane;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function () {
        Nutupane = function () {
            this.table = {
                showColumns: function () {},
                getSelected: function () {
                    return [{id: 1}, {id: 2}, {id: 3}];
                },
                rows: [{dummy: 1}, {dummy: 2}, {dummy: 3}],
                resource: {
                    results: [1,2,3],
                    total: 3,
                    subtotal: 3
                },

                numSelected: 0
            };
            this.get = function () {};
            this.invalidate = function () {};
            this.refresh = function () {
                var deferred = $q.defer();
                return {
                    $promise: deferred.promise,
                    then : function () {}
                }
            }
        };
        ProductBulkAction = {
            removeProducts: function () {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            },
            syncProducts: function () {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };

        Product = {};
        $uibModal = {
            open: function () {
                return {
                    closed: {
                        then: function () {}
                    }
                }
            }
        };
    });

    beforeEach(inject(function (_Notification_, $controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        Notification = _Notification_;

        $controller('ProductsController', {
            $scope: $scope,
            $location: $location,
            $uibModal: $uibModal,
            Nutupane: Nutupane,
            Product: Product,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: 'foo',
            Notification: Notification
        });
    }));

    it('attaches the nutupane table to the scope', function () {
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

    it("can remove multiple products", function () {
        spyOn(ProductBulkAction, 'removeProducts').and.callThrough();

        $scope.removeProducts();

        expect(ProductBulkAction.removeProducts).toHaveBeenCalledWith(_.extend({ids: [1, 2, 3]}, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can sync products", function () {
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

    it("can disable repo discovery before refresh", function () {
        expect($scope.disableRepoDiscovery).toBe(true);
    });

    it("can refresh table on repo discovery", function () {
        $scope.goToDiscoveries();
        expect($scope.table.rows).toEqual([]);
        expect($scope.table.resource.total).toBe(0);
        expect($scope.table.resource.subtotal).toBe(0);
        expect($scope.table.resource.results).toEqual([]);
    });
});

