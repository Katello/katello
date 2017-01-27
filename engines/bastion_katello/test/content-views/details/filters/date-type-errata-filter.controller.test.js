describe('Controller: DateTypeErrataFilterController', function() {
    var $scope, Rule, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        Rule = $injector.get('MockResource').$new();

        Notification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter.get({id: 1});
        $scope.filter.rules = [{types: []}];
        $scope.filter['content_view'] = {id: 1};

        $scope.rule = {
            types: ['bugfix', 'security', 'enhancement']
        };

        $controller('DateTypeErrataFilterController', {
            $scope: $scope,
            translate: translate,
            Rule: Rule,
            Notification: Notification
        });
    }));

    it("provides a method to update the selected types", function() {
        $scope.updateTypes({'bugfix': true, 'security': true});

        expect($scope.rule.types).toEqual(['bugfix', 'security']);
    });

    it("should provide a method to add errata to the filter", function () {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.rule, $scope.filter);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

});
