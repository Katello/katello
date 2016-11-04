describe('Controller: ErrataFilterListController', function() {
    var $scope, Rule, GlobalNotification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            translate = $injector.get('translateMock'),
            Filter = $injector.get('MockResource').$new(),
            Nutupane = function() {
                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: [1]}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        GlobalNotification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter.get({id: 1});
        $scope.filter.rules = [
            {id: 1, 'errata_id': 1}
        ];

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'delete');

        $controller('ErrataFilterListController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            Filter: Filter,
            Rule: Rule,
            GlobalNotification: GlobalNotification
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("should provide a method to remove errata from the filter", function () {
        spyOn(GlobalNotification, 'setSuccessMessage');

        $scope.removeErrata();

        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.filter.rules.length).toBe(0);
    });

});
