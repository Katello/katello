describe('Controller: DebsController', function() {
    var $scope,
        $location,
        $controller,
        dependencies,
        Deb,
        Nutupane;

    beforeEach(module('Bastion.debs', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function() {}
            };
            this.get = function() {};
            this.setParams = function (params) {};
            this.getParams = function (params) { return {}; };
            this.refresh = function () {};
            this.getAllSelectedResults = function () {};
        };
        Errata = {};
    });

    beforeEach(inject(function(_$controller_, $rootScope, _$location_, MockResource, translateMock) {
        Deb = MockResource.$new();
        //Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Deb: Deb,
            //Task: Task,
            //Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        };

        $controller('DebsController', dependencies);
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it("allows the filtering of packages", function () {
        $scope.showApplicable = false;
        $scope.showUpgradable = false;
        $scope.toggleFilters();
        expect($scope.table.params['packages_restrict_applicable']).toBe(false)
        expect($scope.table.params['packages_restrict_upgradable']).toBe(false)
    });

    it("ensures showApplicable is true if showUpgradable is true", function () {
        $scope.showApplicable = false;
        $scope.showUpgradable = true;
        $scope.toggleFilters();
        expect($scope.table.params['packages_restrict_applicable']).toBe(true)
        expect($scope.table.params['packages_restrict_upgradable']).toBe(true)
    });
});
