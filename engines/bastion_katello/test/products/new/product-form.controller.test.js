describe('Controller: ProductFormController', function() {
    var $scope,
        FormUtils,
        GlobalNotification,
        $httpBackend;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            Provider = $injector.get('MockResource').$new(),
            GPGKey = $injector.get('MockResource').$new(),
            SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        FormUtils = $injector.get('FormUtils');
        GlobalNotification = $injector.get('GlobalNotification');

        $scope.productForm = $injector.get('MockForm');
        $scope.productTable = {
            addRow: function() {},
            closeItem: function() {}
        };

        $scope.panel = {};

        $controller('ProductFormController', {
            $scope: $scope,
            $http: $http,
            $q: $q,
            Product: Product,
            Provider: Provider,
            GPGKey: GPGKey,
            SyncPlan: SyncPlan,
            FormUtils: FormUtils,
            GlobalNotification: GlobalNotification
        });
    }));

    it('should attach a new product resource on to the scope', function() {
        expect($scope.product).toBeDefined();
    });

    it('should save a new product resource', function() {
        var product = $scope.product;

        spyOn($scope.productTable, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(product, '$save').and.callThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.productTable.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('products.details.repositories.index',
                                                         {productId: $scope.product.id})
    });

    it('should fail to save a new product resource', function() {
        var product = $scope.product;

        product.failed = true;
        spyOn(product, '$save').and.callThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.productForm['name'].$invalid).toBe(true);
        expect($scope.productForm['name'].$error.messages).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.product.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });

});

