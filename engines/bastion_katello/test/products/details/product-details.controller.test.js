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

describe('Controller: ProductDetailsController', function() {
    var $scope;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state'),
            Product = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {productId: 1};
        $scope.removeRow = function() {};

        $controller('ProductDetailsController', {
            $scope: $scope,
            $state: $state,
            Product: Product
        });
    }));

    it("gets the system using the Product service and puts it on the $scope.", function() {
        expect($scope.product).toBeDefined();
    });

    it('provides a method to remove a product', function() {
        spyOn($scope, 'transitionTo');
        spyOn($scope, 'removeRow');

        $scope.removeProduct($scope.product);

        expect($scope.transitionTo).toHaveBeenCalledWith('products.index');
        expect($scope.removeRow).toHaveBeenCalledWith($scope.product.id);
    });

    describe("it provides a method to get the read only reason", function() {
        var product;

        beforeEach(function () {
            product = {$resolved: true};
            $scope.denied = function() {};
        });

        it ("if the permission was denied", function() {
            spyOn($scope, 'denied').andReturn(true);
            expect($scope.getReadOnlyReason(product)).toBe('permissions');
            expect($scope.denied).toHaveBeenCalledWith('destroy_products', product);
        });

        it("if the product was published in a content view", function() {
            product['published_content_view_ids'] = [1, 2];
            expect($scope.getReadOnlyReason(product)).toBe('published');
        });

        it("if the product is a Red Hat product", function() {
            product['published_content_view_ids'] = [];
            product.redhat = true;
            expect($scope.getReadOnlyReason(product)).toBe('redhat');
        });
    });
});
