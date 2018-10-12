describe('Controller: ProductDetailsInfoController', function() {
    var $scope, translate, Notification, Product, ContentCredential, MenuExpander;

    beforeEach(module(
        'Bastion.products',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            SyncPlan = $injector.get('MockResource').$new();
            ContentCredential = $injector.get('MockResource').$new();

        Product = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        MenuExpander = {};

        translate = function(message) {
            return message;
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $controller('ProductDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Notification: Notification,
            Product: Product,
            SyncPlan: SyncPlan,
            ContentCredential: ContentCredential,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it('provides a method to retrieve available content credential', function() {
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
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.product);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should fail to save the product', function() {
        spyOn(Notification, 'setErrorMessage');

        $scope.product.failed = true;

        $scope.save($scope.product);

        expect(Notification.setErrorMessage).toHaveBeenCalled();
    });
});
