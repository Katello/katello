describe('Controller: NewProductController', function() {
    var $scope;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Product = $injector.get('MockResource').$new;

        $scope = $injector.get('$rootScope').$new();

        $controller('NewProductController', {
            $scope: $scope,
            Product: Product,
            CurrentOrganization: 'ACME_Corporation'
        });
    }));

    it('attaches a new product resource onto the scope', function() {
        expect($scope.product).toBeDefined();
    });

});

