describe('Controller: PackageRepositoriesController', function() {
    var $scope, translate, Nutupane, ContentView, Environment, Repository,
        CurrentOrganization;

    beforeEach(module('Bastion.packages', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            MockResource = $injector.get('MockResource'),
            $q = $injector.get('$q');


        translate = function (string) {
            return string;
        };

        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function () {},
                allResultsSelectCount: function () {}
            };
            this.enableSelectAllResults = function () {};
            this.getAllSelectedResults = function () {
                return {include: [1, 2, 3]};
            };
            this.setParams = function (params) {
                this.table.params = params;
            };
            this.refresh = function () {};
            this.load = function () {
                return {then: function () {}}
            };
            this.setSearchKey = function () {};
        };

        Environment = MockResource.$new();
        Environment.mockResources = {results: [{id: 5, library: true}]};

        ContentView = MockResource.$new();
        Repository = MockResource.$new();

        CurrentOrganization = 'foo';
        
        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {packageId: 1};

        $controller('PackageRepositoriesController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Nutupane: Nutupane,
            ContentView: ContentView,
            Repository: Repository,
            Environment: Environment,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("puts the package repositories table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });
});
