describe('Controller: ErrataController', function() {
    var $scope,
        $location,
        $controller,
        dependencies,
        Errata,
        Task,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

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

        Task = {
            registerSearch: function() {},
            unregisterSearch: function () {}
        };
    });

    beforeEach(inject(function(_$controller_, $rootScope, _$location_, MockResource, translateMock) {
        Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Errata: Errata,
            Task: Task,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        };

        $controller('ErrataController', dependencies);
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('errata.index');
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
        spyOn($scope, 'transitionTo');
        spyOn($scope.nutupane, 'getAllSelectedResults');

        $scope.goToNextStep();

        expect($scope.nutupane.getAllSelectedResults).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('errata.apply.select-content-hosts');
    });
    
    it('allows the setting of the repositoryId via a query string parameter', function () {
        $location.search('repositoryId', '1');

        $controller('ErrataController', dependencies);

        expect($scope.repository.id).toBe(1);
    });

    it('sets the incrementalUpdateInProgress to true if an incremental update is in progress', function () {
        spyOn(Task, 'registerSearch').andCallFake(function (params, callback) {
            callback([1]);
        });

        $scope.checkIfIncrementalUpdateRunning();

        expect(Task.registerSearch).toHaveBeenCalled();
        expect($scope.incrementalUpdateInProgress).toBe(true);
    });

    it('sets the incrementalUpdateInProgress to false if no incremental update is in progress', function () {
        spyOn(Task, 'registerSearch').andCallFake(function (params, callback) {
            callback([]);
        });

        $scope.checkIfIncrementalUpdateRunning();

        expect(Task.registerSearch).toHaveBeenCalled();
        expect($scope.incrementalUpdateInProgress).toBe(false);
    });
});
