describe('Controller: DebRepositoriesController', function() {
    var $scope, translate, Nutupane, Repository,
        CurrentOrganization;

    beforeEach(module('Bastion.debs', 'Bastion.test-mocks'));

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

        Repository = MockResource.$new();

        CurrentOrganization = 'foo';
        
        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {packageId: 1};

        $controller('DebRepositoriesController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Nutupane: Nutupane,
            Repository: Repository,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("puts the deb repositories table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });
});
