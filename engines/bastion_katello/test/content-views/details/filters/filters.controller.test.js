describe('Controller: FiltersController', function() {
    var $scope,
        Filter;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            Nutupane = function() {
                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: [1]}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        Filter = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.contentView = ContentView.get({id: 1});

        $controller('FiltersController', {
            $scope: $scope,
            translate: translate,
            Filter: Filter,
            Nutupane: Nutupane
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("should provide a method to remove one or more filters", function() {
        $scope.removeFilters();

        expect($scope.successMessages.length).toBe(1);
    });

    it("provides a way to get the filter's state", function() {
        expect($scope.getFilterState({type: 'erratum', rules: [{types: false}]})).
            toBe('content-views.details.filters.details.erratum.list({filterId: filter.id})');
        expect($scope.getFilterState({type: 'erratum', rules: [{types: true}]})).
            toBe('content-views.details.filters.details.erratum.dateType({filterId: filter.id})');
        expect($scope.getFilterState({type: 'rpm'})).
            toBe('content-views.details.filters.details.rpm({filterId: filter.id})');
        expect($scope.getFilterState({type: 'package_group'})).
            toBe('content-views.details.filters.details.package_group.list({filterId: filter.id})');
    });
});
