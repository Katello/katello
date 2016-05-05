describe('Controller: ProductRepositoriesController', function() {
    var $scope, $q, expectedTable, expectedIds, Repository, RepositoryBulkAction, Nutupane, DownloadPolicy;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks', 'Bastion.repositories'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            rows = [{id: 1, name: 'blah'}, {id: 2, name: 'blah2'}];

        expectedTable = {
            rows: rows,
            showColumns: function() {},
            getSelected: function() {
                return [rows[1]];
            },
            selectAll: function() {},
            allSelected: false
        };

        expectedIds = _.map(rows, 'id');

        Nutupane = function() {
            this.table = expectedTable;
            this.get = function() {};
            this.query = function() {};
            this.refresh = function() {};
            this.getAllSelectedResults = function() {
                return {
                    included: { ids: expectedIds }
                };
            };
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        Repository = $injector.get('MockResource').$new();

        RepositoryBulkAction = $injector.get('MockResource').$new();
        RepositoryBulkAction.syncRepositories = function(params, success, error) {
            return {'$promise': $q.defer().promise};
        };
        RepositoryBulkAction.removeRepositories = function(params, success, error) {
            return {'$promise': $q.defer().promise};
        };

        DownloadPolicy = $injector.get('DownloadPolicy');

        $controller('ProductRepositoriesController', {
            $scope: $scope,
            Repository: Repository,
            RepositoryBulkAction: RepositoryBulkAction,
            CurrentOrganization: 'ACME',
            Nutupane: Nutupane,
            DownloadPolicy: DownloadPolicy
        });
    }));

    it("sets up the repositories nutupane table", function() {
        expect($scope.table).toBe(expectedTable);
    });

    it("provides a way to remove all of the selected repositories in the table", function() {
        spyOn(RepositoryBulkAction, 'removeRepositories').and.callThrough();

        $scope.removeSelectedRepositories();
        expect(RepositoryBulkAction.removeRepositories).toHaveBeenCalledWith({ids: expectedIds},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a way to sync all of the selected repositories in the table", function() {
        var errorFunction = jasmine.any(Function);

        spyOn(RepositoryBulkAction, 'syncRepositories').and.callThrough();

        $scope.syncSelectedRepositories();
        expect(RepositoryBulkAction.syncRepositories).toHaveBeenCalledWith({ids: expectedIds},
            jasmine.any(Function), errorFunction);
    });


    it("should provide a valid reason for a repo deletion disablement", function() {
        var product = {id: 100, $resolved: true};

        $scope.denied = function (perm, prod) {
            expect(perm).toBe("destroy_products");
            return true;
        };
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe("permissions");
        expect($scope.canRemoveRepositories(product)).toBe(false);

        $scope.denied = function (perm, prod) {
            return false;
        };

        product.redhat = true;
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe("redhat");
        expect($scope.canRemoveRepositories(product)).toBe(false);

        product.redhat = false;
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe(null);
        expect($scope.canRemoveRepositories(product)).toBe(true);
    });

});
