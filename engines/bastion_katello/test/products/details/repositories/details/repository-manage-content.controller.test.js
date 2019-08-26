describe('Controller: RepositoryManageContentController', function() {
    var $scope, translate, Repository, Nutupane, PuppetModule, Package, PackageGroup, DockerManifestList,  DockerManifest, OstreeBranch, DockerTag, ModuleStream, AnsibleCollection;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $state = $injector.get('$state'),
            Package = $injector.get('MockResource').$new();

        Repository = $injector.get('MockResource').$new();
        Repository.removeContent = function() {};

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            productId: '1',
            repositoryId: '1'
        };
        $state = { current: { name: 'manage-content.packages' } };

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
        };

        translate = function(message) {
            return message;
        };

        $controller('RepositoryManageContentController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Repository: Repository,
            PuppetModule: PuppetModule,
            DockerTag: DockerTag,
            Package: Package,
            PackageGroup: PackageGroup,
            DockerManifest: DockerManifest,
            DockerManifestList: DockerManifestList,
            OstreeBranch: OstreeBranch,
            ModuleStream: ModuleStream,
            AnsibleCollection: AnsibleCollection
        });
    }));

    it('sets up a nutupane', function() {
        expect($scope.contentNutupane).not.toBe(undefined);
        expect($scope.table).toBeDefined();
    });

    it('can remove content', function() {
        spyOn(Repository, 'removeContent');
        $scope.repository = {id: 'doh!'};
        $scope.table.getSelected = function() {
            return [{id: 'foo'}];
        };

        $scope.removeContent();

        expect(Repository.removeContent).toHaveBeenCalledWith({id: $scope.repository.id, ids: ['foo']},
            jasmine.any(Function), jasmine.any(Function));
    });

    it('can fetch tags from a manifest', function() {
        var tags, manifest;
        manifest = {tags: [{id: 1, repository_id: 1}, {id: 2, repository_id: 2}]};
        tags = $scope.tagsForManifest(manifest);
        expect(tags.length).toBe(1);
        expect(tags[0].id).toBe(1);
    });

    it('updates selectability appropriately', function() {
        var manifest;
        manifest = {manifest_lists: [1]};
        $scope.currentState = "docker-manifests";
        $scope.updateSelectable(manifest);
        expect(manifest.unselectable).toBe(true);

        manifest = {manifest_lists: []};
        $scope.updateSelectable(manifest);
        expect(manifest.unselectable).not.toBe(true);

        $scope.currentState = "packages";
        manifest = {manifest_lists: [1]};
        $scope.updateSelectable(manifest);
        expect(manifest.unselectable).not.toBe(true);
    });
});
