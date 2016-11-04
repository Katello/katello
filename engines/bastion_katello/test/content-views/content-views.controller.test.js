describe('Controller: ContentViewsController', function() {
    var $scope,
        ContentView,
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
    });

    beforeEach(inject(function($injector) {
        $scope = $injector.get('$rootScope').$new();
        var $controller = $injector.get('$controller');

        $controller('ContentViewsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentView: ContentView,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

});

