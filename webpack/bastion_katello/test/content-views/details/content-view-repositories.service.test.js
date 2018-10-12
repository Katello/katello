describe('Service: ContentViewRepositoriesService', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var repositoryUtil = $injector.get('ContentViewRepositoriesUtil');

        $scope = $injector.get('$rootScope').$new();
        repositoryUtil($scope);
    }));

    it("should put a product object on the scope", function() {
        expect($scope.product).toBeDefined();
    });

    it("should provide a way to filter repositories by all products", function() {
        var repository = {product: {id: 1}};

        expect($scope.repositoryFilter(repository)).toBe(true);
    });

    it("should provide a way to filter repositories by product", function() {
        var repository = {product: {id: 1}};

        $scope.product = {id: 2};

        expect($scope.repositoryFilter(repository)).toBe(false);
    });

    it("should watch table rows and set the scope products list", function() {
        $scope.table = {rows: []};
        $scope.$digest();

        expect(Object.keys($scope.products).length).toBe(1);

        $scope.table['rows'] = [{product: {id: 1}}];
        $scope.$digest();

        expect(Object.keys($scope.products).length).toBe(2);
    });

    it('should provide a method to get all selected repositories', function () {
        var Nutupane = function () {
                this.getAllSelectedResults = function () {
                    return {included: {ids: [1, 2]}};
                };

                this.table = {};
            },
            nutupane = new Nutupane();

        $scope.filteredItems = [{id: 1}];

        expect($scope.getSelected(nutupane).length).toBe(1);
    });

});
