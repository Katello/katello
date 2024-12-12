describe('Controller: DebsController', function() {
    var $scope,
        $location,
        $controller,
        dependencies,
        Deb,
        Repository,
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
        Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Deb: Deb,
            //Task: Task,
            Repository: Repository,
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

    it('should set the repository_id param on Nutupane when a repository is chosen', function () {
        spyOn($scope.nutupane, 'setParams');
        spyOn($scope.nutupane, 'refresh');

        $scope.repository = {id: 1};
        $scope.$apply();

        expect($scope.nutupane.setParams).toHaveBeenCalledWith({'repository_id': 1});
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it('allows the setting of the repositoryId via a query string parameter', function () {
        $location.search('repositoryId', '1');

        $controller('DebsController', dependencies);

        expect($scope.repository.id).toBe(1);
    });

});
