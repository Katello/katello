describe('Controller: AvailablePackageGroupFilterController', function() {
    var $scope, Rule, rule, Nutupane, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        Nutupane = function() {
            this.table = {};
            this.getAllSelectedResults = function () {
                return {included: {resources: ['packageGroup']}};
            };
            this.removeRow = function (item, field) {
                return true;
            };
        };

        Notification = {
            setSuccessMessage: function () {}
        };

        Rule = $injector.get('MockResource').$new();
        rule = Rule.get({id: 1});

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter({id: 1, rules: [rule]});

        $controller('AvailablePackageGroupFilterController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            Filter: Filter,
            Rule: Rule,
            Notification: Notification
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("should provide a method to add package groups to the filter", function () {
        spyOn(Notification, 'setSuccessMessage');
        spyOn(rule, '$save').and.callThrough();

        $scope.addPackageGroups($scope.filter);

        expect(rule.$save).toHaveBeenCalled();
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.filter.rules.length).toBe(2);
    });

});
