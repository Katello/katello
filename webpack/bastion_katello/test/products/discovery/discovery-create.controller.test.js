describe('Controller: DiscoveryCreateController', function() {
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
            ContentCredential = $injector.get('MockResource').$new(),
            translate;

        translate = function (message) {
            return message;
        };

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        Product = $injector.get('MockResource').$new();
        FormUtils = $injector.get('FormUtils');

        $scope.$stateParams.rows = [];

        $controller('DiscoveryCreateController', {
            $scope: $scope,
            $q: $q,
            CurrentOrganization: 'ACME',
            Product: Product,
            Repository: Repository,
            ContentCredential: ContentCredential,
            FormUtils: FormUtils,
            translate: translate
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
        expect($scope.contentCredentials).toBeDefined();
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

    it('should return "Not started" for repo', function() {
        var repo = {
            name: "abc"
        };

        expect($scope.createStatusMessages(repo)).toEqual("Not started");
    });

    it('should return messages for repo', function() {
        var repo = {
            messages: "here we go"
        };

        expect($scope.createStatusMessages(repo)).toEqual("here we go");
    });

    it('should return ok icon', function() {
        var repo = {
            name: "abc",
            created: true
        };

        expect($scope.createStatusIcon(repo)).toEqual("pficon pficon-ok");
    });

    it('should return spinner icon', function() {
        var repo = {
            name: "abc",
            created: false,
            creating: true
        };

        expect($scope.createStatusIcon(repo)).toEqual("fa fa-spinner fa-spin");
    });

    it('should return no icon', function() {
        var repo = {
            name: "abc",
            created: false,
            creating: false
        };

        expect($scope.createStatusIcon(repo)).toEqual("");
    });

    it('should return error icon', function() {
        var repo = {
            name: "abc",
            created: false,
            creating: false,
            messages: "some error"
        };

        expect($scope.createStatusIcon(repo)).toEqual("pficon pficon-error-circle-o");
    });
});
