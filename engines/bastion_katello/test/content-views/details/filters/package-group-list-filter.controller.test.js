describe('Controller: PackageGroupFilterListController', function() {
    var $scope, Rule, Nutupane, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

            Notification = {
                setSuccessMessage: function () {}
            };

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
            Nutupane: Nutupane,
            Notification: Notification
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("should provide a method to remove package groups from the filter", function () {
        spyOn(Notification, 'setSuccessMessage');

        $scope.removePackageGroups();

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.filter.rules.length).toBe(0);
    });

});
