describe('Controller: AvailableErrataFilterController', function() {
    var $scope, Rule, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
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
        $scope.filter = Filter({id: 1});
        $scope.rule = {};

        $controller('AvailableErrataFilterController', {
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

    it("should provide a method to add errata to the filter", function () {
        spyOn($scope.nutupane, 'refresh');
        spyOn($scope.nutupane.table, 'selectAllResults');
        spyOn(Notification, 'setSuccessMessage');

        $scope.addErrata($scope.filter);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.table.selectAllResults).toHaveBeenCalledWith(false);
    });

    it("should provide a method to update the errata based on type", function () {
        spyOn($scope.nutupane, 'refresh');
        $scope.updateTypes({'security': true, 'enhancement': false, 'bugfix': false});

        expect($scope.nutupane.getParam('types[]')).toContain('security');
        expect($scope.nutupane.getParam('types[]')).not.toContain('bugfix');
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it("should update the errata by start date", function () {
        var date = new Date();
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['start_date'] = date;
        $scope.$digest();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('start_date')).toBe(date.toISOString().split('T')[0]);
    });

    it("should update the errata by end date", function () {
        var date = new Date();
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['end_date'] = date;
        $scope.$digest();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('end_date')).toBe(date.toISOString().split('T')[0]);
    });

    it("should update the errata by when asked to search on the updated date", function () {
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['date_type'] = "updated" ;
        $scope.updateDateType();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('sort_by')).toBe("updated");
        expect($scope.nutupane.getParam('date_type')).toBe("updated");
    });

    it("should update the errata by when asked to search on the issued date", function () {
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['date_type'] = "issued" ;
        $scope.updateDateType();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('sort_by')).toBe("issued");
        expect($scope.nutupane.getParam('date_type')).toBe("issued");
    });

});
