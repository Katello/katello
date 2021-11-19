describe('Controller: RepositoryDetailsController', function() {
    var $scope, $state, $uibModal, translate, Notification, repository, syncableRepo;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(function () {
        $uibModal = {
            open: function () {
                return {
                    closed: {
                        then: function () {}
                    }
                }
            }
        };
    });

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            Repository = $injector.get('MockResource').$new();

        repository = new Repository();

        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');

        $scope.repository = repository;
        $scope.denied = function() {return false};
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };

        translate = function(message) {
            return message;
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        syncableRepo = {content_type: 'yum', url: 'foo', last_sync: {state: 'stopped'}};

        $controller('RepositoryDetailsController', {
            $scope: $scope,
            $state: $state,
            $uibModal: $uibModal,
            translate: translate,
            Notification: Notification,
            Product: Product,
            Repository: Repository
        });
    }));

    it('can open a reclaim space modal', function () {
        var result;
        spyOn($uibModal, 'open').and.callThrough();

        $scope.openReclaimSpaceModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('repository-details-reclaim-space-modal.html');
        expect(result.controller).toBe('RepositoryDetailsReclaimSpaceModalController');
    });

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
            expect(perm).toBe("deletable");
            return true;
        };
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe("permissions");
        expect($scope.canRemove(repository, product)).toBe(false);

        $scope.denied = function (perm, prod) {
            return false;
        };
        repository.promoted = true;
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe(null);
        expect($scope.canRemove(repository, product)).toBe(true);

        repository.promoted = false;
        repository.product_type = "redhat";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe(null);
        expect($scope.canRemove(repository, product)).toBe(true);

        repository.product_type = "custom";
        expect($scope.getRepoNonDeletableReason(repository, product)).toBe(null);
        expect($scope.canRemove(repository, product)).toBe(true);
    });

    it('should properly hide sync button when syncing', function() {
        expect($scope.hideSyncButton(syncableRepo, false)).toBe(false);
        syncableRepo.last_sync.state = 'pending';
        expect($scope.hideSyncButton(syncableRepo, false)).toBe(true);
    });

    it('should properly hide sync button when no url', function() {
        syncableRepo.url = undefined;
        expect($scope.hideSyncButton(syncableRepo, false)).toBe(true);
    });

    it('should provide a way to remove a repository', function() {
        repository.id = 1;

        spyOn($scope, 'transitionTo');

        $scope.removeRepository(repository);

        expect($scope.transitionTo).toHaveBeenCalledWith('product.repositories', {productId: 1});
    });

    it('should provide a way to view versions on a repository', function() {
        repository.id = 1;
        repository.content_view_versions = [
            {
                "id": 28,
                "version": "3.0",
                "content_view_id": 15,
                "content_view_name": "cv6"
            },
            {
                "id": 36,
                "version": "1.0",
                "content_view_id": 23,
                "content_view_name": "cv1"
            },
            {
                "id": 42,
                "version": "3.0",
                "content_view_id": 23,
                "content_view_name": "cv1"
            }
        ];
        expect($scope.repositoryVersions()).toEqual(
          {
            15: [{
                id: 28,
                content_view_id: 15,
                content_view_name: 'cv6',
                version: '3.0'
          }],
            23: [
              {
                id: 36,
                content_view_id: 23,
                content_view_name: 'cv1',
                version: '1.0'
              },
              {
                id: 42,
                content_view_id: 23,
                content_view_name: 'cv1',
                version: '3.0'
              }]
          });
  });
});
