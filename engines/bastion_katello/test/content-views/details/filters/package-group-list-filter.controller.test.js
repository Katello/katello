describe('Controller: PackageGroupFilterListController', function() {
    var $scope,
        Rule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            Nutupane = function() {
                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: ['9d288c85-1d40-4545-b88d-a11ac30cea93']}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter({id: 1});
        $scope.filter.rules = [
            {id: 1, name: 'packageGroup', uuid: '9d288c85-1d40-4545-b88d-a11ac30cea93'}
        ];

        Rule = $injector.get('MockResource').$new();

        $controller('PackageGroupFilterListController', {
            $scope: $scope,
            translate: translate,
            Filter: Filter,
            Rule: Rule,
            Nutupane: Nutupane
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("should provide a method to remove package groups from the filter", function () {
        $scope.removePackageGroups();

        expect($scope.successMessages.length).toBe(1);
        expect($scope.filter.rules.length).toBe(0);
    });

});
