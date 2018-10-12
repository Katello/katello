describe('Controller: PuppetModulesController', function() {
    var $scope,
        PuppetModule,
        Nutupane;

    beforeEach(module('Bastion.puppet-modules', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function() {}
            };
        };
    });

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();

        $controller('PuppetModulesController', {
            $scope: $scope,
            Nutupane: Nutupane,
            PuppetModule: PuppetModule,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
