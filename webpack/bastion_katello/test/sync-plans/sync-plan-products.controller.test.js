describe('Controller: SyncPlanProductsController', function() {
    var $scope,
        translate,
        SyncPlan,
        Nutupane;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        SyncPlan = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        SyncPlan.removeProducts = function() {};

        translate = function(message) {
            return message;
        };

        Nutupane = function() {
            this.table = {};
        };

        $controller('SyncPlanProductsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            SyncPlan: SyncPlan,
            Nutupane: Nutupane
        });

        $scope.syncPlan = new SyncPlan({
            id: 2,
            products: [{id: 1, name: "lalala"}, {id: 2, name: "hello!"}]
        });
    }));

    it('attaches the products nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it("allows removing products groups from the sync plan", function() {
        var expected = {product_ids: [1]};
        spyOn(SyncPlan, 'removeProducts');

        $scope.table.getSelected = function() {
            return [{id: 1, name: "lalala"}];
        };

        $scope.removeProducts();
        expect(SyncPlan.removeProducts).toHaveBeenCalledWith({id: 2}, expected, jasmine.any(Function), jasmine.any(Function));
    });
});
