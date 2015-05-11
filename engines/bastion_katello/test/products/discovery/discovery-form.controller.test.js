describe('Controller: DiscoveryFormController', function() {
    var $scope,
        Product,
        FormUtils,
        $httpBackend;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            Provider = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new(),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        Product = $injector.get('MockResource').$new();
        FormUtils = $injector.get('FormUtils');

        $controller('DiscoveryFormController', {
            $scope: $scope,
            $http: $http,
            $q: $q,
            CurrentOrganization: 'ACME',
            Provider: Provider,
            Product: Product,
            Repository: Repository,
            GPGKey: GPGKey,
            FormUtils: FormUtils
        });
    }));

    it('should provide a way to determine if a repository is currently being created', function() {
        expect($scope.creating()).toEqual($scope.createRepoChoices.creating);
    });

    it('should attach an object to the scope that defines create choices for a repository', function() {
        expect($scope.createRepoChoices).toBeDefined();
    });

    it('should fetch available products and put them on the scope', function() {
        expect($scope.products).toBeDefined();
    });

    it('should set the repository choices existingProductId', function() {
        expect($scope.createRepoChoices.existingProductId).toBeDefined();
    });

    it('should set gpgkeys', function(){
        expect($scope.gpgKeys).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.createRepoChoices.product.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });

    it('should save a product if creating repos on a new product', function() {
        spyOn(Product, 'save');

        $scope.createRepoChoices.newProduct = "true";
        $scope.createRepos()

        expect(Product.save).toHaveBeenCalled();
    });

    it('should transition to repositories page if there are no repositories to be created', function() {
        spyOn($scope, 'transitionTo');

        $scope.createRepos();

        expect($scope.transitionTo).toHaveBeenCalled();
    });

});

