describe('Controller: ProductDetailsInfoController', function() {
    var $scope, translate, MenuExpander;

    beforeEach(module(
        'Bastion.products',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            SyncPlan = $injector.get('MockResource').$new();
            GPGKey = $injector.get('MockResource').$new();

        Product = $injector.get('MockResource').$new();
        Product.sync = function() {};

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        MenuExpander = {};

        translate = function(message) {
            return message;
        };

        $controller('ProductDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Product: Product,
            SyncPlan: SyncPlan,
            GPGKey: GPGKey,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it('provides a method to retrieve available gpg keys', function() {
        var promise = $scope.gpgKeys(),
            promiseCalled = false;

        expect(promise.then).toBeDefined();
        promise.then(function(gpgKeys) {
            expect(gpgKeys).toBeDefined();
            expect(gpgKeys).toContain({id: null});
            promiseCalled = true;
        });

        $scope.$apply();
        expect(promiseCalled).toBe(true);
    });

    it('should save the product and return a promise', function() {
        var promise = $scope.save($scope.product);

        expect(promise.then).toBeDefined();
    });

    it('should save the product successfully', function() {
        $scope.save($scope.product);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the product', function() {
        $scope.product.failed = true;

        $scope.save($scope.product);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('provides a way to sync a product', function() {
        spyOn(Product, 'sync');

        $scope.syncProduct();

        expect(Product.sync).toHaveBeenCalledWith({id: $scope.$stateParams.productId}, 
            jasmine.any(Function), jasmine.any(Function));
    });
});
