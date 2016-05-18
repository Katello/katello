describe('Controller: FilterDetailsController', function() {
    var $scope, Filter;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        Filter = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentViewId: 1,
            filterId: 1
        };
        spyOn(Filter, 'get').and.callThrough();

        $controller('FilterDetailsController', {
            $scope: $scope,
            Filter: Filter
        });
    }));

    it("should put on the scope an individual filter object", function() {
        expect(Filter.get).toHaveBeenCalledWith({content_view_id: 1, filterId: 1});
    });

    it("should provide a way to update the filter", function () {
        var filter = Filter.get({id: 1});
        spyOn(filter, '$update');
        $scope.updateFilter(filter);
        expect(filter.$update).toHaveBeenCalled();
    });

});
