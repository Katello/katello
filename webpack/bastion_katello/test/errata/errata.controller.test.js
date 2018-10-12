describe('Controller: ErrataController', function() {
    var $scope,
        $state,
        $location,
        $controller,
        dependencies,
        Erratum,
        IncrementalUpdate,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(function() {
        $state = {
            transitionTo: function () {}
        };

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

        IncrementalUpdate = {
            getIncrementalUpdates: function () {},
            setBulkErrata: function () {}
        };
    });

    beforeEach(inject(function(_$controller_, $rootScope, _$location_, MockResource, translateMock) {
        Erratum = MockResource.$new();
        Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $state: $state,
            $location: $location,
            Nutupane: Nutupane,
            Erratum: Erratum,
            IncrementalUpdate: IncrementalUpdate,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        };

        $controller('ErrataController', dependencies);
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the total errata count on the scope', function () {
        expect($scope.errataCount).toBe(2);
    });

    it('gets a list of yum repositories for the organization', function () {
        expect($scope.repositories[0]).toBe($scope.repository);
        expect($scope.repositories.length).toBe(2);
    });

    it('should have a list of repositories that include an all option', function () {
        expect($scope.repositories[0]['id']).toBe('all');
    });

    it("allows the filtering of errata", function () {
        $scope.showApplicable = false;
        $scope.showInstallable = false;
        $scope.toggleFilters();
        expect($scope.table.params['errata_restrict_applicable']).toBe(false)
        expect($scope.table.params['errata_restrict_installable']).toBe(false)
    });

    it("ensures showApplicable is true if showInstallable is true", function () {
        $scope.showApplicable = false;
        $scope.showInstallable = true;
        $scope.toggleFilters();
        expect($scope.table.params['errata_restrict_applicable']).toBe(true)
        expect($scope.table.params['errata_restrict_installable']).toBe(true)
    });

    it('should set the repository_id param on Nutupane when a repository is chosen', function () {
        spyOn($scope.nutupane, 'setParams');
        spyOn($scope.nutupane, 'refresh');

        $scope.repository = {id: 1};
        $scope.$apply();

        expect($scope.nutupane.setParams).toHaveBeenCalledWith({'repository_id': 1});
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it("provides a way to go to the next apply step", function () {
        spyOn(IncrementalUpdate, 'setBulkErrata');
        spyOn($state, 'transitionTo');
        spyOn($scope.nutupane, 'getAllSelectedResults');

        $scope.goToNextStep();

        expect(IncrementalUpdate.setBulkErrata).toHaveBeenCalled();
        expect($scope.nutupane.getAllSelectedResults).toHaveBeenCalled();
        expect($state.transitionTo).toHaveBeenCalledWith('apply-errata.select-content-hosts');
    });
    
    it('allows the setting of the repositoryId via a query string parameter', function () {
        $location.search('repositoryId', '1');

        $controller('ErrataController', dependencies);

        expect($scope.repository.id).toBe(1);
    });


    it('gets the incremental updates from the incremental update service', function () {
        spyOn(IncrementalUpdate, 'getIncrementalUpdates');

        $controller('ErrataController', dependencies);

        expect(IncrementalUpdate.getIncrementalUpdates).toHaveBeenCalled();
    });
});
