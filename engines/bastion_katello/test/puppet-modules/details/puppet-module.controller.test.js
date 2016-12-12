describe('Controller: PuppetModuleController', function() {
    var $scope,
        PuppetModule;

    beforeEach(module('Bastion.puppet-modules', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();
        PuppetModule = MockResource.$new();

        $scope.$stateParams = {
            puppetModuleId: 1
        };

        $controller('PuppetModuleController', {
            $scope: $scope,
            PuppetModule: PuppetModule
        });
    }));

    it('attaches puppet module to scope', function() {
        expect($scope.puppetModule).toBeDefined();
        expect($scope.panel.loading).toBe(false);
    });
});
