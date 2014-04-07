/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

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
        $httpBackend.expectGET('/api/products').respond(products);

        Product.queryPaged(function(products) {
            expect(products.records.length).toBe(2);
        });
    });

    it('provides a way to update a product', function() {
        var updatedProduct = products.records[0];

        updatedProduct.name = 'NewProductName';
        $httpBackend.expectPUT('/api/products/1').respond(updatedProduct);

        Product.update({ id: 1 }, function(product) {
            expect(product).toBeDefined();
            expect(product.name).toBe('NewProductName');
        });
    });

    it('provides a way to sync a product', function() {
        $httpBackend.expectPOST('/api/products/1/sync').respond(products[0]);

        Product.sync({ id: 1 });
    });

    it('provides a way to attach a sync plan to a product', function() {
        var updatedProduct = products.records[0];

        updatedProduct.sync_plan_id = 2;
        $httpBackend.expectPOST('/api/products/1/sync_plan').respond(updatedProduct);

        Product.updateSyncPlan({ id: 1, plan_id: 2 }, function(product) {
            expect(product).toBeDefined();
            expect(product.sync_plan_id).toBe(2);
        });
    });
});

describe('Factory: ProductBulkAction', function() {
    var $httpBackend,
        ProductBulkAction,
        productParams,
        productGroupParams;

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
        $httpBackend.expect('PUT', '/api/products/bulk/destroy', productParams).respond();
        ProductBulkAction.removeProducts(productParams);
    });

    it('provides a way to sync products', function() {
        $httpBackend.expect('PUT', '/api/products/bulk/sync', productParams).respond();
        ProductBulkAction.syncProducts(productParams);
    });

    it('provides a way to update product sync plans', function() {
        $httpBackend.expect('PUT', '/api/products/bulk/sync_plan', productParams).respond();
        ProductBulkAction.updateProductSyncPlan(productParams);
    });
});
