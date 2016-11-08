describe('Controller: ProductDetailsController', function() {
    var $scope, Product;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        Product = $injector.get('MockResource').$new();
        Product.sync = function() {};

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {productId: 1};

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

        $scope.removeProduct($scope.product);

        expect($scope.transitionTo).toHaveBeenCalledWith('products');
    });

    describe("it provides a method to get the read only reason", function() {
        var product;

        beforeEach(function () {
            product = {$resolved: true};
            $scope.denied = function() {};
        });

        it ("if the permission was denied", function() {
            spyOn($scope, 'denied').and.returnValue(true);
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

    it('provides a way to sync a product', function() {
        spyOn(Product, 'sync');

        $scope.syncProduct();

        expect(Product.sync).toHaveBeenCalledWith({id: $scope.$stateParams.productId},
            jasmine.any(Function), jasmine.any(Function));
    });
});
