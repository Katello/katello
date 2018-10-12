describe('Factory: ProductBulkAction', function() {
    var $httpBackend,
        ProductBulkAction,
        productParams;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(module(function() {
        var productIds = [1, 2, 3];

        productParams = {ids: productIds};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ProductBulkAction = $injector.get('ProductBulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to remove products', function() {
        $httpBackend.expect('PUT', 'katello/api/v2/products/bulk/destroy', productParams).respond();
        ProductBulkAction.removeProducts(productParams);
    });

    it('provides a way to sync products', function() {
        $httpBackend.expect('PUT', 'katello/api/v2/products/bulk/sync', productParams).respond();
        ProductBulkAction.syncProducts(productParams);
    });

    it('provides a way to update product sync plans', function() {
        $httpBackend.expect('PUT', 'katello/api/v2/products/bulk/sync_plan', productParams).respond();
        ProductBulkAction.updateProductSyncPlan(productParams);
    });
});
