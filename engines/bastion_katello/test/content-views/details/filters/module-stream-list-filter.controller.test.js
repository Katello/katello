describe('Controller: ModuleStreamFilterListController', function() {
    var $scope, Rule, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            translate = $injector.get('translateMock'),
            ModuleStream = $injector.get('MockResource').$new(),
            expected = {id: 1, module_stream_id: 3, name: "module",  stream: "stream"},

            Nutupane = function() {
                this.table = {rows: [expected]};
                this.getAllSelectedResults = function () {
                    return {included: {ids: [expected["module_stream_id"]]}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        Notification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = ModuleStream.get({id: 1});
        $scope.filter.rules = [ expected ];

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'delete');

        $controller('ModuleStreamFilterListController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            ModuleStream: ModuleStream,
            Rule: Rule,
            Notification: Notification
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("should provide a method to remove module stream from the filter", function () {
        spyOn(Notification, 'setSuccessMessage');

        $scope.removeModuleStreams();

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.filter.rules.length).toBe(0);
    });

});
