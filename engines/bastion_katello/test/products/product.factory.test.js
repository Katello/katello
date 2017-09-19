describe('Factory: Product', function() {
    var $httpBackend,
        products;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        products = {
            records: [
                { name: 'Product1', id: 1 },
                { name: 'Product2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Product = $injector.get('Product');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of products', function() {
        $httpBackend.expectGET('katello/api/v2/products').respond(products);

        Product.queryPaged(function(products) {
            expect(products.records.length).toBe(2);
        });
    });

    it('provides a way to update a product', function() {
        var updatedProduct = products.records[0];

        updatedProduct.name = 'NewProductName';
        $httpBackend.expectPUT('katello/api/v2/products/1').respond(updatedProduct);

        Product.update({ id: 1 }, function(product) {
            expect(product).toBeDefined();
            expect(product.name).toBe('NewProductName');
        });
    });

    it('provides a way to sync a product', function() {
        $httpBackend.expectPOST('katello/api/v2/products/1/sync').respond(products[0]);

        Product.sync({ id: 1 });
    });

    it('provides a way to attach a sync plan to a product', function() {
        var updatedProduct = products.records[0];

        updatedProduct.sync_plan_id = 2;
        $httpBackend.expectPOST('katello/api/v2/products/1/sync_plan').respond(updatedProduct);

        Product.updateSyncPlan({ id: 1, plan_id: 2 }, function(product) {
            expect(product).toBeDefined();
            expect(product.sync_plan_id).toBe(2);
        });
    });
});
