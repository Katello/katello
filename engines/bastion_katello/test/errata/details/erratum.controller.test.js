describe('Controller: ErratumController', function() {
    var $scope, Erratum;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        Erratum = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {errataId: 1};

        $controller('ErratumController', {
            $scope: $scope,
            Erratum: Erratum
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.errata).toBeDefined();
    });
});
