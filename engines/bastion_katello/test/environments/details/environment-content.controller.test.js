describe('Controller: EnvironmentContentController', function() {
    var $scope,
        Repository,
        ContentService;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            $location = $injector.get('$location'),
            $state = $injector.get('$state');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {environmentId: 1};

        $state.current = {name: 'environment.repositories'};

        Repository = $injector.get('MockResource').$new(),
        ContentService = $injector.get('ContentService');
        spyOn(ContentService, 'buildNutupane').and.returnValue({
            table: {},
            params: {},
            masterOnly: false,
            getParams: function () { return this.params; },
            setParams: function (params) { this.params = params; },
            refresh: function () {}
        });

        spyOn(Repository, 'queryUnpaged').and.returnValue({
            results: Repository.mockResources,
            $promise: {then: function (func) { func.call(this, Repository.mockResources); }}
        });

        $controller('EnvironmentContentController', {
            $scope: $scope,
            ContentService: ContentService,
            ContentView: ContentView,
            Repository: Repository,
            translate: translate,
            $location: $location
        });

    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("puts a nutupane object on the scope from the Content Service", function() {
        expect(ContentService.buildNutupane).toHaveBeenCalledWith({'environment_id': 1});
        expect($scope.nutupane).toBeDefined();
        expect($scope.nutupane.masterOnly).toBe(true);
    });

    it("provides a method to set the repository id when selected", function () {
        $scope.repositorySelected({id: 1});

        expect($scope.nutupane.getParams()['repository_id']).toBe(1);
    });

    it("sets the repository_id to undefined when all repositories set", function () {
        $scope.repositorySelected({id: 'all'});

        expect($scope.nutupane.getParams()['repository_id']).toBe(undefined);
    });

    it("provides a method to set the content view id when selected", function () {
        $scope.contentViewSelected({id: 1, versions: [{id: 2, 'environment_ids': [1]}]});

        expect($scope.nutupane.getParams()['content_view_version_id']).toBe(2);
    });

    it("sets the content_view_id to undefined when all content views set", function () {
        $scope.contentViewSelected({id: ''});

        expect($scope.nutupane.getParams()['content_view_version_id']).toBe(undefined);
    });

    it("sets the repository_id to null when content view is selected", function () {
        $scope.contentViewSelected({id: 1, versions: [{id: 2, 'environment_ids': [1]}]});

        expect($scope.nutupane.getParams()['repository_id']).toBe(null);
    });

    it("should fetch repositories every time a content view is selected", function () {
        $scope.contentViewSelected({id: 1, versions: [{id: 2, 'environment_ids': [1]}]});

        expect(Repository.queryUnpaged).toHaveBeenCalled();
        expect($scope.nutupane.getParams()['repository_id']).toBe(null);
    });

});

