describe('Controller: ContentViewsController', function() {
    var $scope,
        ContentView,
        RepositoryTypesService,
        Nutupane;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function() {}
        };
        ContentView = {};
        RepositoryTypesService = {
          pulp3Supported: function(){},
        };
    });

    beforeEach(inject(function($injector) {
        $scope = $injector.get('$rootScope').$new();
        var $controller = $injector.get('$controller');

        $controller('ContentViewsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentView: ContentView,
            CurrentOrganization: 'CurrentOrganization',
            RepositoryTypesService: RepositoryTypesService
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

});

