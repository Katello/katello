describe('Controller: PuppetModuleContentViewsController', function() {
    var $scope;

    beforeEach(module('Bastion.puppet-modules', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.setSearchKey = function() {};
            this.table = {
                params: {},
                showColumns: function() {}
            };
        };
    });

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();
        ContentViewVersion = MockResource.$new();

        $controller('PuppetModuleContentViewsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentViewVersion: ContentViewVersion,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches a details table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('provides a method to generate comma separated environment names', function() {
        var environments = [{name: 'dev'}, {name: 'test'}];
        expect($scope.environmentNames(environments)).toBe('dev,test');
    });
});
