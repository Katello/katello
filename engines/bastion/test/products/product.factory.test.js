/**
 * Copyright 2013 Red Hat, Inc.
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

    beforeEach(module('Bastion.products'));

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
    });

    it('provides a way to get a list of products', function() {
        $httpBackend.expectGET('/katello/api/products').respond(products);

        Product.query(function(products) {
            expect(products.records.length).toBe(2);
        });
    });

    it('provides a way to update a product', function() {
        var updatedProduct = products.records[0];

        updatedProduct.name = 'NewProductName';
        $httpBackend.expectPUT('/katello/api/products/1').respond(updatedProduct);

        Product.update({ id: 1 }, function(product) {
            expect(product).toBeDefined();
            expect(product.name).toBe('NewProductName');
        });
    });

});

