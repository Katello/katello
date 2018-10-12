describe('Controller: FiltersController', function() {
    var $scope, Filter, Notification;

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

        Notification = {
            setSuccessMessage: function () {}
        };

        Filter = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.contentView = ContentView.get({id: 1});

        $controller('FiltersController', {
            $scope: $scope,
            translate: translate,
            Filter: Filter,
            Nutupane: Nutupane,
            Notification: Notification
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("should provide a method to remove one or more filters", function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.removeFilters();

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it("provides a way to get the filter's state", function() {
        expect($scope.getFilterState({type: 'erratum', rules: [{types: false}]})).
            toBe('content-view.yum.filter.erratum.list({filterId: filter.id})');
        expect($scope.getFilterState({type: 'erratum', rules: [{types: true}]})).
            toBe('content-view.yum.filter.erratum.dateType({filterId: filter.id})');
        expect($scope.getFilterState({type: 'rpm'})).
            toBe('content-view.yum.filter.rpm({filterId: filter.id})');
        expect($scope.getFilterState({type: 'package_group'})).
            toBe('content-view.yum.filter.package_group.list({filterId: filter.id})');
    });
});
