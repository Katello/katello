describe('Controller: AvailableModuleStreamFilterController', function() {
    var $scope, Rule, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ModuleStream = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            Nutupane = function() {
                var params = {};

                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: [1]}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
                this.enableSelectAllResults = function () {};
                this.table.selectAllResults = function () {};
                this.refresh = function () {};
                this.addParam = function (key, value) {
                    params[key] = value;
                }
                this.getParam = function (key) {
                    return params[key];
                }
            };

        Notification = {
            setSuccessMessage: function () {}
        };

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'save');

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = ModuleStream({id: 1});
        $scope.rule = {};

        $controller('AvailableModuleStreamFilterController', {
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

    it("should provide a method to add module streams to the filter", function () {
        spyOn($scope.nutupane, 'refresh');
        spyOn($scope.nutupane.table, 'selectAllResults');
        spyOn(Notification, 'setSuccessMessage');

        $scope.addModuleStreams($scope.filter);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.table.selectAllResults).toHaveBeenCalledWith(false);
    });
});
