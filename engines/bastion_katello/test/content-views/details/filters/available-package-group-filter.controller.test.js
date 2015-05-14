describe('Controller: AvailablePackageGroupFilterController', function() {
    var $scope, Rule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            Nutupane = function() {
                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {resources: ['packageGroup']}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'save');

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter({id: 1, rules: []});

        $controller('AvailablePackageGroupFilterController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            Filter: Filter,
            Rule: Rule
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("should provide a method to add package groups to the filter", function () {
        $scope.addPackageGroups($scope.filter);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.filter.rules.length).toBe(1);
    });

});
