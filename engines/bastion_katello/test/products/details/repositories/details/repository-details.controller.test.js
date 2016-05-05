describe('Controller: RepositoryDetailsController', function() {
    var $scope, $state, translate, repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new();

        repository = new Repository();

        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        translate = function(message) {
            return message;
        };

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        $controller('RepositoryDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Product: Product,
            Repository: Repository
        });
    }));

    it('retrieves and puts a repository on the scope', function() {
        expect($scope.repository).toBeDefined();
    });

    it('retrieves and puts the product on the scope', function() {
        expect($scope.product).toBeDefined();
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        expect($scope.syncInProgress($scope.repository['sync_state'])).toBe(false);
    });

    it('should provide a method to determine if a repository is currently being syncd', function() {
        var lastSync = {state: 'running'};
        expect($scope.syncInProgress(lastSync)).toBe(true);
    });

    it("provides a way to sync a repository", function() {
        spyOn($state, 'go');

        $scope.syncRepository($scope.repository);
        expect($state.go).toHaveBeenCalled();
    });

    it("should provide a valid reason for a repo deletion disablement", function() {
        var product = {id: 100, $resolved: true},
            repository = {id: 200, $resolved: true};

        $scope.denied = function (perm, prod) {
            expect(perm).toBe("destroy_products");
            return true;
        };
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("permissions");
        expect($scope.canRemove(repository, product)).toBe(false);

        $scope.denied = function (perm, prod) {
            return false;
        };
        repository.promoted = true;
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("published");
        expect($scope.canRemove(repository, product)).toBe(false);

        repository.promoted = false;
        repository.product_type = "redhat";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("redhat");
        expect($scope.canRemove(repository, product)).toBe(false);

        repository.product_type = "custom";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe(null);
        expect($scope.canRemove(repository, product)).toBe(true);
    });

    it('should provide a way to remove a repository', function() {
        repository.id = 1;

        spyOn($scope, 'transitionTo');

        $scope.removeRepository(repository);

        expect($scope.transitionTo).toHaveBeenCalledWith('product.repositories', {productId: 1});
    });
});
