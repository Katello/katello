describe('Controller: PackageDetailsController', function() {
    var $scope, Package;

    beforeEach(module('Bastion.packages', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        Package = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {packageId: 1};

        $controller('PackageDetailsController', {
            $scope: $scope,
            Package: Package
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.package).toBeDefined();
    });
});
