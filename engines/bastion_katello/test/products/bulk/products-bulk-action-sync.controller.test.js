describe('Controller: ProductsBulkActionSyncController', function() {
    var $scope, $q, translate, ProductBulkAction, selected;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        selected = [1, 2, 3];
        ProductBulkAction = {
            syncProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };
        translate = function() {};
    });

    beforeEach(inject(function($controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;

        $scope.actionParams = {};
        $scope.getSelectedProductIds = function () { return selected; };

        $controller('ProductsBulkActionSyncController', {
            $scope: $scope,
            ProductBulkAction: ProductBulkAction,
            translate: translate
        });
    }));

    it("can sync products", function() {
        spyOn(ProductBulkAction, 'syncProducts').andCallThrough();
        $scope.syncProducts();

        expect(ProductBulkAction.syncProducts).toHaveBeenCalledWith({ids: [1, 2, 3]}, jasmine.any(Function));
    });

});
