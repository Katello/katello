describe('Controller: ErrataFilterController', function() {
    var $scope, Filter;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        $scope = $injector.get('$rootScope').$new();

        $controller('ErrataFilterController', {
            $scope: $scope
        });
    }));

    it("adds an empty rule to the scope", function() {
        expect($scope.rule).toBeDefined();
    });

    it("adds a date object to control date picker to the scope", function() {
        expect($scope.date).toBeDefined();
        expect($scope.date.startOpen).toBe(false);
        expect($scope.date.endOpen).toBe(false);
    });

    it("adds types to the scope", function() {
        expect($scope.types).toBeDefined();
        expect($scope.types.enhancement).toBe(true);
        expect($scope.types.bugfix).toBe(true);
        expect($scope.types.security).toBe(true);
    });

    it("adds a method to open the start date picker", function() {
        $scope.openStartDate({preventDefault: function () {}, stopPropagation: function () {}});

        expect($scope.date.startOpen).toBe(true);
        expect($scope.date.endOpen).toBe(false);
    });

    it("adds a method to open the end date picker", function() {
        $scope.openEndDate({preventDefault: function () {}, stopPropagation: function () {}});

        expect($scope.date.startOpen).toBe(false);
        expect($scope.date.endOpen).toBe(true);
    });

    it("should provide a method to filter errata by type", function () {
        var errata = {
            type: 'security'
        };

        $scope.types = {'security': true};
        expect($scope.errataFilter(errata)).toBe(true);

        $scope.types = {'bugfix': false};
        expect($scope.errataFilter(errata)).toBe(false);
    });

    it("should provide a method to filter errata that were issued after a particular date", function () {
        var errata = {
            type: 'security',
            issued: new Date('1/1/2012')
        };

        $scope.types = {'security': true};

        $scope.rule['start_date'] = new Date('1/1/2012');
        expect($scope.errataFilter(errata)).toBe(true);

        $scope.rule['start_date'] = new Date('1/2/2012');
        expect($scope.errataFilter(errata)).toBe(false);
    });

    it("should provide a method to filter errata that were issued before a particular date", function () {
        var errata = {
            type: 'security',
            issued: new Date('1/2/2012')
        };

        $scope.types = {'security': true};

        $scope.rule['end_date'] = new Date('1/1/2012');
        expect($scope.errataFilter(errata)).toBe(false);

        $scope.rule['end_date'] = new Date('1/3/2012');
        expect($scope.errataFilter(errata)).toBe(true);
    });

    it("should provide a method to check if an errata type is the only one selected", function () {
        var selections = {enhancement: false, bugfix: false, security: true};

        expect($scope.onlySelected(selections, 'security')).toBe(true);

        selections = {enhancement: false, bugfix: false, security: false};
        expect($scope.onlySelected(selections, 'bugfix')).toBe(false);
    });

});
