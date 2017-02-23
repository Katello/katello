describe('Controller: RepositoryAdvancedSyncController', function() {
    var $scope, $state, repository, Repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        Repository = $injector.get('MockResource').$new();
        repository = new Repository({id: 1});
        $scope = $injector.get('$rootScope').$new();
        $state = $injector.get('$state');

        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1
        };
        $scope.repository = repository;

        Repository.sync = function(params, callback) {
            callback.call(this, {'state': 'running'});
        };

        $controller('RepositoryAdvancedSyncController', {
            $scope: $scope,
            $state: $state,
            Repository: Repository
        });
    }));

    it('can sync a regular sync', function() {
        spyOn(Repository, 'sync');

        $scope.advancedSync('regular');

        expect(Repository.sync).toHaveBeenCalledWith({id: $scope.repository.id},
            jasmine.any(Function), jasmine.any(Function));
    });

    it('can sync a skip_metadata_check sync', function() {
        spyOn(Repository, 'sync');

        $scope.advancedSync('skipMetadataCheck');

        expect(Repository.sync).toHaveBeenCalledWith({id: $scope.repository.id, skip_metadata_check: true},
            jasmine.any(Function), jasmine.any(Function));
    });

    it('can sync a validate_contents sync', function() {
        spyOn(Repository, 'sync');

        $scope.advancedSync('validateContents');

        expect(Repository.sync).toHaveBeenCalledWith({id: $scope.repository.id, validate_contents: true},
            jasmine.any(Function), jasmine.any(Function));
    });
});
