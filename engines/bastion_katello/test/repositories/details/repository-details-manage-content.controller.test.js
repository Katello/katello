describe('Controller: RepositoryManageContentController', function() {
    var $scope, translate, Repository, Nutupane, PuppetModule, Package, PackageGroup, DockerImage;

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
            productId: 1,
            repositoryId: 1,
        };
        $state = { current: { name: 'products.details.repositories.manage-content.packages' } };

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
            Package: Package,
            PackageGroup: PackageGroup,
            DockerImage: DockerImage,
        });
    }));

    it('sets up a nutupane', function() {
        expect($scope.contentNutupane).not.toBe(undefined);
        expect($scope.detailsTable).not.toBe(undefined);
    });

    it('can remove content', function() {
        spyOn(Repository, 'removeContent');
        $scope.repository = {id: 'doh!'};
        $scope.detailsTable.getSelected = function() {
            return [{id: 'foo'}];
        };

        $scope.removeContent();

        expect(Repository.removeContent).toHaveBeenCalledWith({id: $scope.repository.id, uuids: ['foo']},
            jasmine.any(Function), jasmine.any(Function));
    });

    it('formats tags for a docker image', function() {
        var repoId = 1,
            tags,
            image,
            output = "latest, 2.11";

        tags = [
                {"name": "latest", "repository_id": 1},
                {"name": "latest", "repository_id": 2},
                {"name": "2.11",   "repository_id": 1}
               ];
        image = {"tags": tags};

        expect($scope.formatRepoDockerTags(image, repoId)).toEqual(output);
    });

});
