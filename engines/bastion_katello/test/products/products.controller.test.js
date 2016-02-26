describe('Controller: ProductsController', function() {
    var $scope,
        GlobalNotification,
        Nutupane;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        Product = {};
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        GlobalNotification = _GlobalNotification_;

        $controller('ProductsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Product: Product,
            CurrentOrganization: 'CurrentOrganization',
            GlobalNotification: GlobalNotification
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.productTable).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.productTable.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.index');
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
});

